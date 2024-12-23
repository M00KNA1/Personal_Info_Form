import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        controller.createPreviewData(in: viewContext) //preview data

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving preview context: \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Personal_Info_Form")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("Error loading persistent stores: \(error), \(error.userInfo)")
            }
        }
    }
    
private func createPreviewData(in context: NSManagedObjectContext) {
        for i in 0..<5 {
            let newPerson = Person(context: context)
            newPerson.title = "Miss"
            newPerson.firstname = "Sample"
            newPerson.lastname = "User\(i)"
            newPerson.email = "user\(i)@example.com"
            newPerson.phonenumber = "123-456-789\(i)"
        }
    }

func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
                // Handle error appropriately (e.g., show an alert or retry saving)
            }
        }
    }
}
