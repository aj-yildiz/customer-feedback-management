@IsTest
public class TestServiceFactory extends fflib_Application.ServiceFactory {
    private Map<Type, Object> mockInstances;
    
    public TestServiceFactory() {
        super(new Map<Type, Type>());
        this.mockInstances = new Map<Type, Object>();
    }
    
    public override void setMock(Type serviceType, Object mockInstance) {
        mockInstances.put(serviceType, mockInstance);
    }
    
    public override Object newInstance(Type serviceInterfaceType) {
        if (mockInstances.containsKey(serviceInterfaceType)) {
            return mockInstances.get(serviceInterfaceType);
        }
        return super.newInstance(serviceInterfaceType);
    }
} 