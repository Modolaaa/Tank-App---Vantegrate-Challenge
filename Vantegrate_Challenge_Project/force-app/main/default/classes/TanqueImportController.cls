/**
 * @description Controller that handles tank import operations, including fetching tank types, 
 * creating new tank types, and bulk-importing tanks from CSV data.
 * @author Modola Lautaro
 * @date 2025-10-02
 */

public with sharing class TanqueImportController {
    
    /**
     * @description Retrieves the list of available Tank Types from Salesforce.
     * @return List<Tipo_de_tanque__c> - List of Tank Type records ordered by Name ASC.
     * @throws AuraHandledException if an error occurs while querying Tank Types.
     */
    @AuraEnabled(cacheable=true)
    public static List<Tipo_de_tanque__c> getTiposTanque() {
        try {
            return [
                SELECT Id, Name 
                FROM Tipo_de_tanque__c 
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener tipos de tanque: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates a new Tank Type record based on provided field values.
     * @param tipoTanqueData Map<String, Object> - Key-value pairs representing Tank Type fields.
     * @return Id - The Id of the newly created Tank Type record.
     * @throws AuraHandledException if an error occurs while inserting the Tank Type.
     */
    @AuraEnabled
    public static Id crearTipoTanque(Map<String, Object> tipoTanqueData) {
        try {
            Tipo_de_tanque__c nuevoTipo = new Tipo_de_tanque__c();
            
            if (tipoTanqueData.containsKey('capacidad__c')) {
                nuevoTipo.capacidad__c = (Decimal)tipoTanqueData.get('capacidad__c');
            }
            if (tipoTanqueData.containsKey('peso__c')) {
                nuevoTipo.peso__c = (Decimal)tipoTanqueData.get('peso__c');
            }
            if (tipoTanqueData.containsKey('Marca__c')) {
                nuevoTipo.Marca__c = (String)tipoTanqueData.get('Marca__c');
            }
            if (tipoTanqueData.containsKey('precio_de_lista__c')) {
                nuevoTipo.precio_de_lista__c = (Decimal)tipoTanqueData.get('precio_de_lista__c');
            }
            if (tipoTanqueData.containsKey('alto__c')) {
                nuevoTipo.alto__c = (Decimal)tipoTanqueData.get('alto__c');
            }
            if (tipoTanqueData.containsKey('ancho__c')) {
                nuevoTipo.ancho__c = (Decimal)tipoTanqueData.get('ancho__c');
            }
            if (tipoTanqueData.containsKey('Profundidad__c')) {
                nuevoTipo.Profundidad__c = (Decimal)tipoTanqueData.get('Profundidad__c');
            }
            if (tipoTanqueData.containsKey('Material__c')) {
                nuevoTipo.Material__c = (String)tipoTanqueData.get('Material__c');
            }
            
            insert nuevoTipo;
            
            return nuevoTipo.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al crear tipo de tanque: ' + e.getMessage());
        }
    }
    
    /**
     * @description Imports multiple Tank records based on CSV-like input data.
     * @param tanquesData List<Map<String, Object>> - List of key-value pairs representing Tanks.
     * @return Integer - The number of Tank records successfully inserted.
     * @throws AuraHandledException if an error occurs while inserting Tanks.
     */
    @AuraEnabled
    public static Integer importarTanques(List<Map<String, Object>> tanquesData) {
        try {
            List<Tanque__c> tanquesAInsertar = new List<Tanque__c>();
            
            for (Map<String, Object> tanqueData : tanquesData) {
                Tanque__c nuevoTanque = new Tanque__c();
                
                if (tanqueData.containsKey('numero_de_serie_externo__c')) {
                    nuevoTanque.numero_de_serie_externo__c = (String)tanqueData.get('numero_de_serie_externo__c');
                }
                if (tanqueData.containsKey('ubicacion__c')) {
                    nuevoTanque.ubicacion__c = (String)tanqueData.get('ubicacion__c');
                }
                if (tanqueData.containsKey('fecha_de_fabricacion__c')) {
                    String fechaStr = (String)tanqueData.get('fecha_de_fabricacion__c');
                    if (String.isNotBlank(fechaStr)) {
                        try {
                            // Try to parse it in ISO format (YYYY-MM-DD)
                            nuevoTanque.fecha_de_fabricacion__c = Date.valueOf(fechaStr);
                        } catch (Exception ex) {
                                // If it fails, try other common formats
                                // Format DD/MM/YYYY or MM/DD/YYYY
                            List<String> partesFecha = fechaStr.split('/');
                            if (partesFecha.size() == 3) {
                                Integer dia = Integer.valueOf(partesFecha[0]);
                                Integer mes = Integer.valueOf(partesFecha[1]);
                                Integer anio = Integer.valueOf(partesFecha[2]);
                                nuevoTanque.fecha_de_fabricacion__c = Date.newInstance(anio, mes, dia);
                            }
                        }
                    }
                }
                if (tanqueData.containsKey('observaciones__c')) {
                    nuevoTanque.observaciones__c = (String)tanqueData.get('observaciones__c');
                }
                if (tanqueData.containsKey('tipo_de_tanque__c')) {
                    nuevoTanque.tipo_de_tanque__c = (String)tanqueData.get('tipo_de_tanque__c');
                }
                
                tanquesAInsertar.add(nuevoTanque);
            }
            
            if (!tanquesAInsertar.isEmpty()) {
                insert tanquesAInsertar;
            }
            
            return tanquesAInsertar.size();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al importar tanques: ' + e.getMessage());
        }
    }
}