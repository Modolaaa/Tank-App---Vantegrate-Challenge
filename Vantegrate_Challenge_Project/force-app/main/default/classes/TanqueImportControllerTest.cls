/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TanqueImportControllerTest {
    
    @TestSetup
    static void makeData() {
        // Create test tipos de tanque
        List<Tipo_de_tanque__c> tiposTanque = new List<Tipo_de_tanque__c>();
        
        Tipo_de_tanque__c tipo1 = new Tipo_de_tanque__c(
            capacidad__c = 1000,
            peso__c = 500,
            Marca__c = 'Rotoplas',
            precio_de_lista__c = 5000,
            alto__c = 2,
            ancho__c = 1.5,
            Profundidad__c = 1.5,
            Material__c = 'Acero'
        );
        tiposTanque.add(tipo1);
        
        Tipo_de_tanque__c tipo2 = new Tipo_de_tanque__c(
            capacidad__c = 2000,
            peso__c = 800,
            Marca__c = 'Rotoplas',
            precio_de_lista__c = 8000,
            alto__c = 3,
            ancho__c = 2,
            Profundidad__c = 2,
            Material__c = 'Plastico'
        );
        tiposTanque.add(tipo2);
        
        insert tiposTanque;
    }
    
    @isTest
    static void testGetTiposTanque() {
        Test.startTest();
        List<Tipo_de_tanque__c> tipos = TanqueImportController.getTiposTanque();
        Test.stopTest();
        
        System.assertEquals(2, tipos.size(), 'Debería haber 2 tipos de tanque');
        System.assertNotEquals(null, tipos[0].Id, 'El Id no debería ser nulo');
        System.assertNotEquals(null, tipos[0].Name, 'El Name no debería ser nulo');
    }
    
    @isTest
    static void testCrearTipoTanque() {
        Map<String, Object> tipoTanqueData = new Map<String, Object>{
            'capacidad__c' => 1500,
            'peso__c' => 600,
            'Marca__c' => 'Rotoplas',
            'precio_de_lista__c' => 6500,
            'alto__c' => 2.5,
            'ancho__c' => 1.8,
            'Profundidad__c' => 1.8,
            'Material__c' => 'Acero'
        };
        
        Test.startTest();
        Id nuevoTipoId = TanqueImportController.crearTipoTanque(tipoTanqueData);
        Test.stopTest();
        
        System.assertNotEquals(null, nuevoTipoId, 'El Id del nuevo tipo no debería ser nulo');
        
        Tipo_de_tanque__c tipoCreado = [
            SELECT Id, capacidad__c, peso__c, Marca__c, precio_de_lista__c, 
                   alto__c, ancho__c, Profundidad__c, Material__c
            FROM Tipo_de_tanque__c
            WHERE Id = :nuevoTipoId
        ];
        
        System.assertEquals(1500, tipoCreado.capacidad__c, 'La capacidad debería ser 1500');
        System.assertEquals('Rotoplas', tipoCreado.Marca__c, 'La marca debería ser Rotoplas');
        System.assertEquals('Acero', tipoCreado.Material__c, 'El material debería ser Acero');
    }
    
    @isTest
    static void testImportarTanques() {
        Tipo_de_tanque__c tipo = [SELECT Id FROM Tipo_de_tanque__c LIMIT 1];
        
        List<Map<String, Object>> tanquesData = new List<Map<String, Object>>();
        
        Map<String, Object> tanque1 = new Map<String, Object>{
            'numero_de_serie_externo__c' => 'TQ-001',
            'ubicacion__c' => 'Almacén A',
            'fecha_de_fabricacion__c' => '2024-01-15',
            'observaciones__c' => 'Tanque nuevo',
            'tipo_de_tanque__c' => tipo.Id
        };
        tanquesData.add(tanque1);
        
        Map<String, Object> tanque2 = new Map<String, Object>{
            'numero_de_serie_externo__c' => 'TQ-002',
            'ubicacion__c' => 'Almacén B',
            'fecha_de_fabricacion__c' => '2024-02-20',
            'observaciones__c' => 'Tanque revisado',
            'tipo_de_tanque__c' => tipo.Id
        };
        tanquesData.add(tanque2);
        
        Test.startTest();
        Integer cantidadImportada = TanqueImportController.importarTanques(tanquesData);
        Test.stopTest();
        
        System.assertEquals(2, cantidadImportada, 'Deberían haberse importado 2 tanques');
        
        List<Tanque__c> tanquesCreados = [
            SELECT Id, numero_de_serie_externo__c, ubicacion__c, fecha_de_fabricacion__c, 
                   observaciones__c, tipo_de_tanque__c
            FROM Tanque__c
        ];
        
        System.assertEquals(2, tanquesCreados.size(), 'Deberían existir 2 tanques en la base de datos');
        System.assertEquals('TQ-001', tanquesCreados[0].numero_de_serie_externo__c, 'El número de serie debería ser TQ-001');
        System.assertEquals(tipo.Id, tanquesCreados[0].tipo_de_tanque__c, 'El tipo de tanque debería coincidir');
    }
    
    @isTest
    static void testImportarTanquesConFechaFormato() {
        Tipo_de_tanque__c tipo = [SELECT Id FROM Tipo_de_tanque__c LIMIT 1];
        
        List<Map<String, Object>> tanquesData = new List<Map<String, Object>>();
        
        Map<String, Object> tanque1 = new Map<String, Object>{
            'numero_de_serie_externo__c' => 'TQ-003',
            'ubicacion__c' => 'Almacén C',
            'fecha_de_fabricacion__c' => '15/01/2024',
            'observaciones__c' => 'Prueba formato fecha',
            'tipo_de_tanque__c' => tipo.Id
        };
        tanquesData.add(tanque1);
        
        Test.startTest();
        Integer cantidadImportada = TanqueImportController.importarTanques(tanquesData);
        Test.stopTest();
        
        System.assertEquals(1, cantidadImportada, 'Debería haberse importado 1 tanque');
        
        Tanque__c tanqueCreado = [
            SELECT Id, fecha_de_fabricacion__c
            FROM Tanque__c
            WHERE numero_de_serie_externo__c = 'TQ-003'
        ];
        
        System.assertNotEquals(null, tanqueCreado.fecha_de_fabricacion__c, 'La fecha no debería ser nula');
    }
    
    @isTest
    static void testCrearTipoTanqueError() {
        Map<String, Object> tipoTanqueData = new Map<String, Object>();
        // Mapa vacío para provocar error
        
        Test.startTest();
        try {
            Id nuevoTipoId = TanqueImportController.crearTipoTanque(tipoTanqueData);
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error al crear tipo de tanque'), 
                         'El mensaje de error debería contener el texto esperado');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testImportarTanquesVacio() {
        List<Map<String, Object>> tanquesData = new List<Map<String, Object>>();
        
        Test.startTest();
        Integer cantidadImportada = TanqueImportController.importarTanques(tanquesData);
        Test.stopTest();
        
        System.assertEquals(0, cantidadImportada, 'No debería haberse importado ningún tanque');
    }
}