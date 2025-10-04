import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadScript } from 'lightning/platformResourceLoader';
import PAPAPARSE from '@salesforce/resourceUrl/papaparse';

// Imports para Tipo_de_tanque__c
import TIPO_TANQUE_OBJECT from '@salesforce/schema/Tipo_de_tanque__c';
import MARCA_FIELD from '@salesforce/schema/Tipo_de_tanque__c.Marca__c';
import MATERIAL_FIELD from '@salesforce/schema/Tipo_de_tanque__c.Material__c';

// Apex methods
import getTiposTanque from '@salesforce/apex/TanqueImportController.getTiposTanque';
import crearTipoTanque from '@salesforce/apex/TanqueImportController.crearTipoTanque';
import importarTanques from '@salesforce/apex/TanqueImportController.importarTanques';

export default class TanqueImporter extends LightningElement {
    // Estados de pantalla
    @track pantallaActual = 1;
    
    // Opciones de selección
    @track seleccionarExistente = true;
    @track crearNuevo = false;
    
    // Datos para tipo de tanque
    @track tipoTanqueSeleccionado = '';
    @track tiposTanqueOptions = [];
    @track marcaOptions = [];
    @track materialOptions = [];
    
    // Datos para nuevo tipo de tanque
    @track nuevoTipo = {
        capacidad: '',
        peso: '',
        marca: '',
        precioLista: '',
        alto: '',
        ancho: '',
        profundidad: '',
        material: ''
    };
    
    // Estado de archivo
    @track archivoSeleccionado = false;
    @track nombreArchivo = '';
    @track csvData = [];
    
    // Control de flujo
    @track errorMessage = '';
    @track isImportando = false;
    @track cantidadTanquesImportados = 0;
    @track tipoTanqueIdFinal = '';
    
    // PapaParse cargado
    papaParseLoaded = false;

    // Getters para control de pantallas
    get isPantallaUno() {
        return this.pantallaActual === 1;
    }

    get isPantallaDos() {
        return this.pantallaActual === 2;
    }

    get isPantallaTres() {
        return this.pantallaActual === 3;
    }

    // Cargar PapaParse
    connectedCallback() {
        loadScript(this, PAPAPARSE)
            .then(() => {
                this.papaParseLoaded = true;
                console.log('PapaParse cargado exitosamente');
            })
            .catch(error => {
                console.error('Error cargando PapaParse:', error);
                this.showToast('Error', 'No se pudo cargar la librería PapaParse', 'error');
            });
    }

    // Obtener información del objeto para picklists
    @wire(getObjectInfo, { objectApiName: TIPO_TANQUE_OBJECT })
    tipoTanqueObjectInfo;

    // Obtener valores de picklist Marca
    @wire(getPicklistValues, { 
        recordTypeId: '$tipoTanqueObjectInfo.data.defaultRecordTypeId', 
        fieldApiName: MARCA_FIELD 
    })
    wiredMarcaPicklist({ error, data }) {
        if (data) {
            this.marcaOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error obteniendo valores de Marca:', error);
        }
    }

    // Obtener valores de picklist Material
    @wire(getPicklistValues, { 
        recordTypeId: '$tipoTanqueObjectInfo.data.defaultRecordTypeId', 
        fieldApiName: MATERIAL_FIELD 
    })
    wiredMaterialPicklist({ error, data }) {
        if (data) {
            this.materialOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error obteniendo valores de Material:', error);
        }
    }

    // Obtener tipos de tanque existentes
    @wire(getTiposTanque)
    wiredTiposTanque({ error, data }) {
        if (data) {
            this.tiposTanqueOptions = data.map(tipo => ({
                label: tipo.Name,
                value: tipo.Id
            }));
        } else if (error) {
            console.error('Error obteniendo tipos de tanque:', error);
            this.showToast('Error', 'No se pudieron cargar los tipos de tanque', 'error');
        }
    }

    // Handlers para checkboxes
    handleSeleccionExistenteChange(event) {
        this.seleccionarExistente = event.target.checked;
        if (this.seleccionarExistente) {
            this.crearNuevo = false;
            this.errorMessage = '';
        }
    }

    handleCrearNuevoChange(event) {
        this.crearNuevo = event.target.checked;
        if (this.crearNuevo) {
            this.seleccionarExistente = false;
            this.errorMessage = '';
        }
    }

    // Handler para selección de tipo de tanque
    handleTipoTanqueChange(event) {
        this.tipoTanqueSeleccionado = event.detail.value;
    }

    // Handler para campos de nuevo tipo
    handleNuevoTipoChange(event) {
        const field = event.target.dataset.field;
        this.nuevoTipo[field] = event.detail.value;
    }

    // Validar y avanzar a pantalla 2
    handleSiguiente() {
        this.errorMessage = '';

        if (!this.seleccionarExistente && !this.crearNuevo) {
            this.errorMessage = 'Debe seleccionar una opción: seleccionar un tipo existente o crear uno nuevo.';
            return;
        }

        if (this.seleccionarExistente) {
            if (!this.tipoTanqueSeleccionado) {
                this.errorMessage = 'Debe seleccionar un tipo de tanque.';
                return;
            }
            this.tipoTanqueIdFinal = this.tipoTanqueSeleccionado;
            this.pantallaActual = 2;
        } else if (this.crearNuevo) {
            // Validar campos requeridos
            if (!this.nuevoTipo.capacidad || !this.nuevoTipo.peso || !this.nuevoTipo.marca || 
                !this.nuevoTipo.precioLista || !this.nuevoTipo.alto || !this.nuevoTipo.ancho || 
                !this.nuevoTipo.profundidad || !this.nuevoTipo.material) {
                this.errorMessage = 'Todos los campos son requeridos para crear un nuevo tipo de tanque.';
                return;
            }

            // Crear el tipo de tanque
            this.crearNuevoTipoTanque();
        }
    }

    // Crear nuevo tipo de tanque
    crearNuevoTipoTanque() {
        const tipoTanqueData = {
            capacidad__c: parseFloat(this.nuevoTipo.capacidad),
            peso__c: parseFloat(this.nuevoTipo.peso),
            Marca__c: this.nuevoTipo.marca,
            precio_de_lista__c: parseFloat(this.nuevoTipo.precioLista),
            alto__c: parseFloat(this.nuevoTipo.alto),
            ancho__c: parseFloat(this.nuevoTipo.ancho),
            Profundidad__c: parseFloat(this.nuevoTipo.profundidad),
            Material__c: this.nuevoTipo.material
        };

        crearTipoTanque({ tipoTanqueData: tipoTanqueData })
            .then(result => {
                this.tipoTanqueIdFinal = result;
                this.showToast('Éxito', 'Tipo de tanque creado correctamente', 'success');
                this.pantallaActual = 2;
            })
            .catch(error => {
                console.error('Error creando tipo de tanque:', error);
                this.errorMessage = 'Error al crear el tipo de tanque: ' + (error.body?.message || error.message);
            });
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.nombreArchivo = file.name;

            // validar que sea csv
            if (!file.name.toLowerCase().endsWith('.csv')) {
                this.errorMessage = 'Por favor seleccione un archivo CSV válido';
                this.archivoSeleccionado = false;
                return;
            }

            this.archivoSeleccionado = true;
            this.errorMessage = '';

            const reader = new FileReader();
            reader.onload = () => {
                const csvText = reader.result;
                this.parsearCSV(csvText); // 👈 acá llamás tu lógica actual
            };
            reader.onerror = (error) => {
                console.error('Error leyendo archivo:', error);
                this.errorMessage = 'Error al leer el archivo CSV';
                this.archivoSeleccionado = false;
            };

            reader.readAsText(file);
        }
    }

    // Parsear CSV con PapaParse
    parsearCSV(csvText) {
        if (!this.papaParseLoaded) {
            this.errorMessage = 'La librería PapaParse aún no está cargada. Intente nuevamente.';
            return;
        }

        try {
            const results = window.Papa.parse(csvText, {
                header: true,
                skipEmptyLines: true,
                dynamicTyping: false,
                trimHeaders: true,
                transform: (value) => value ? value.trim() : value
            });

            console.log('Resultados del parseo:', results);

            if (results.errors && results.errors.length > 0) {
                console.error('Errores al parsear CSV:', results.errors);
                this.errorMessage = 'Error al procesar el archivo CSV: ' + results.errors[0].message;
                return;
            }

            if (!results.data || results.data.length === 0) {
                this.errorMessage = 'El archivo CSV no contiene datos válidos';
                return;
            }

            // Validar que tenga las columnas requeridas
            const primeraFila = results.data[0];
            const columnasRequeridas = ['Nro_Serie', 'FechaFabricacion', 'Ubicacion', 'Observaciones'];
            const columnasFaltantes = columnasRequeridas.filter(col => !primeraFila.hasOwnProperty(col));
            
            if (columnasFaltantes.length > 0) {
                this.errorMessage = `El archivo CSV no tiene las columnas requeridas: ${columnasFaltantes.join(', ')}`;
                return;
            }

            this.csvData = results.data;
            this.errorMessage = '';
            console.log('CSV parseado exitosamente. Registros encontrados:', this.csvData.length);
            
        } catch (error) {
            console.error('Excepción al parsear CSV:', error);
            this.errorMessage = 'Error al procesar el archivo CSV. Verifique el formato.';
        }
    }

    // Importar tanques
    handleImportar() {
        if (!this.archivoSeleccionado || this.csvData.length === 0) {
            this.errorMessage = 'Debe cargar un archivo CSV válido.';
            return;
        }

        this.isImportando = true;
        this.errorMessage = '';

        const tanquesData = this.csvData.map(row => ({
            numero_de_serie_externo__c: row.Nro_Serie,
            ubicacion__c: row.Ubicacion,
            fecha_de_fabricacion__c: row.FechaFabricacion,
            observaciones__c: row.Observaciones,
            tipo_de_tanque__c: this.tipoTanqueIdFinal
        }));

        importarTanques({ tanquesData: tanquesData })
            .then(result => {
                this.cantidadTanquesImportados = result;
                this.pantallaActual = 3;
                this.isImportando = false;
            })
            .catch(error => {
                console.error('Error importando tanques:', error);
                this.errorMessage = 'Error al importar tanques: ' + (error.body?.message || error.message);
                this.isImportando = false;
            });
    }

    // Volver a pantalla anterior
    handleAtras() {
        this.pantallaActual = 1;
        this.archivoSeleccionado = false;
        this.nombreArchivo = '';
        this.csvData = [];
        this.errorMessage = '';
    }

    // Finalizar proceso
    handleFinalizar() {
        this.pantallaActual = 1;
        this.seleccionarExistente = true;
        this.crearNuevo = false;
        this.tipoTanqueSeleccionado = '';
        this.nuevoTipo = {
            capacidad: '',
            peso: '',
            marca: '',
            precioLista: '',
            alto: '',
            ancho: '',
            profundidad: '',
            material: ''
        };
        this.archivoSeleccionado = false;
        this.nombreArchivo = '';
        this.csvData = [];
        this.errorMessage = '';
        this.cantidadTanquesImportados = 0;
        this.tipoTanqueIdFinal = '';
    }

    // Mostrar toast
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
