# Tank App — Vantegrate Challenge

Este proyecto es la solución al desafío técnico de **Vantegrate**, denominado *Tank App*.  
Permite gestionar información de tanques, con visualización, creación, edición e importacion de datos, etc.

---

## 📂 Estructura del proyecto

- `ApexDocumentation/` — Documentación relacionada con clases Apex, comentarios y estructura interna.  
- `Vantegrate_Challenge_Project/` — Carpeta principal con el código de la aplicación (front, back, lógica).  
- `tanques.csv` — Archivo de datos de ejemplo con registros de tanques.  
- `Presentacion Tank App - Vantegrate Challenge.pptx` — Presentación del proyecto para demostrar funcionalidad, diseño y flujo.

---

## 🛠 Tecnologías usadas

- **Salesforce / Apex** — Para la lógica de backend, clases, triggers, etc.  
- **JavaScript / HTML** — Para la parte de la interfaz (Lightning Web Components).

---

## 🚀 Funcionalidades principales

- Cargar datos de tanques a partir .csv 
- Integracion con bitly.  
- Seleccion automatica del mejor tanque disponible o creacion de un pedido.  
- Validaciones de datos.  
- Largo etcetera...

---

## ⚙ Cómo instalar / desplegar

1. Cloná este repositorio:  
   ```bash
   git clone https://github.com/Modolaaa/Tank-App---Vantegrate-Challenge.git
   ```

2. Abrí tu **Org de Salesforce** (sandbox o scratch org, según corresponda).

3. Desplegá las clases, componentes y metadatos dentro de tu Org. Podés usar Salesforce CLI, VS Code con Salesforce Extension Pack, o tu método preferido.

4. Si usás **datos de ejemplo**, importá `tanques.csv`

5. Accedé a la aplicación o pestaña correspondiente desde tu Org y verificá que las funcionalidades estén operativas.

---

## 🧪 Cómo probar

- Ingresá registros nuevos de tanque con distintos valores para verificar validaciones.  
- Modificá registros existentes.  
- Probá escenarios límite: campos vacíos, valores fuera de rango, etc.  
- Compará los datos importados desde `tanques.csv` con los mostrados en la aplicación.

---

## 📝 Créditos

- Desarrollado por **Modola Lautaro** para el challenge de **Vantegrate**.  
- La presentación incluida describe la motivación, decisiones técnicas y flujos del proyecto.

---

