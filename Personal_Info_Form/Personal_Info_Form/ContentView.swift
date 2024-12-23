//
//  ContentView.swift
//  Personal_Info_Form
//
//  Created by 李熙欣 on 2024/12/22.
//
import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var firstName: String = ""
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var streetAddress: String = ""
    @State private var streetAddressLine2: String = ""
    @State private var city: String = ""
    @State private var region: String = ""
    @State private var postalCode: String = ""
    @State private var country: String = ""
    @State private var gender: String = "Female"
    @State private var email: String = ""
    @State private var homePhoneNumber: String = ""
    @State private var isShowingSaveAlert: Bool = false
    @State private var selectedPerson: Person?
    @State private var isShowingSheet: Bool = false

    @StateObject private var countryViewModel = CountryViewModel()

    init(selectedPerson: Person? = nil) {
        _selectedPerson = State(initialValue: selectedPerson)
        _title = State(initialValue: selectedPerson?.title ?? "")
        _firstName = State(initialValue: selectedPerson?.firstname ?? "")
        _middleName = State(initialValue: selectedPerson?.middlename ?? "")
        _lastName = State(initialValue: selectedPerson?.lastname ?? "")
        _dateOfBirth = State(initialValue: selectedPerson?.dateofbirth ?? Date())
        _streetAddress = State(initialValue: selectedPerson?.address ?? "")
        _streetAddressLine2 = State(initialValue: selectedPerson?.address2 ?? "")
        _city = State(initialValue: selectedPerson?.city ?? "")
        _region = State(initialValue: selectedPerson?.region ?? "")
        _postalCode = State(initialValue: selectedPerson?.postcode ?? "")
        _country = State(initialValue: selectedPerson?.country ?? "")
        _gender = State(initialValue: selectedPerson?.gender ?? "Female")
        _email = State(initialValue: selectedPerson?.email ?? "")
        _homePhoneNumber = State(initialValue: selectedPerson?.phonenumber ?? "")
    }

    var body: some View {
        TabView {
            // First Tab: Form to Add/Edit Data
            NavigationView {
                Form {
                    Section(header: Text("Name")) {
                        Picker("Title", selection: $title) {
                            ForEach(["Mr.", "Ms.", "Mrs.", "Miss"], id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding()
                        .cornerRadius(8)
                        TextField("First Name", text: $firstName)
                        TextField("Middle Name", text: $middleName)
                        TextField("Last Name", text: $lastName)
                    }

                    Section(header: Text("Date of Birth")) {
                        DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    }

                    Section(header: Text("Address")) {
                        Picker("Country", selection: $country) {
                            ForEach(countryViewModel.countries, id: \.code) { country in
                                Text(country.name).tag(country.name)
                            }
                        }
                        TextField("Street Address", text: $streetAddress)
                        TextField("Street Address Line 2", text: $streetAddressLine2)
                        TextField("City", text: $city)
                        TextField("Region", text: $region)
                        TextField("Postal / Zip Code", text: $postalCode)
                    }

                    Section(header: Text("Gender")) {
                        Picker("Gender", selection: $gender) {
                            Text("Female").tag("Female")
                            Text("Male").tag("Male")
                        }
                    }

                    Section(header: Text("Contact")) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        TextField("Phone Number", text: $homePhoneNumber)
                            .keyboardType(.phonePad)
                    }

                    HStack {
                        Button(action: {
                            isShowingSaveAlert = true
                        }) {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(firstName.isEmpty || email.isEmpty)
                    }
                }
                .navigationTitle("Personal Information Form")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Form", systemImage: "doc.fill")
            }

            // Second Tab: View Saved Data
            NavigationView {
                RegisteredPersonsView()
                    .navigationTitle("Registered Persons")
            }
            .tabItem {
                Label("Saved Data", systemImage: "list.bullet")
            }
        }
        .alert(isPresented: $isShowingSaveAlert) {
            Alert(
                title: Text("Confirm Save"),
                message: Text("Are you sure you want to save this information?"),
                primaryButton: .destructive(Text("Save")) {
                    savePerson()
                    resetForm() // Clear the form fields after saving
                    dismiss() // Dismiss the form view
                    isShowingSheet = true // Show Saved Data sheet after saving
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            countryViewModel.loadCountries()
        }
        .sheet(isPresented: $isShowingSheet) {
            RegisteredPersonsView() // Show the registered persons view after saving
        }
    }

    private func savePerson() {
        let newPerson = selectedPerson ?? Person(context: viewContext)
        newPerson.title = title
        newPerson.firstname = firstName
        newPerson.middlename = middleName
        newPerson.lastname = lastName
        newPerson.dateofbirth = dateOfBirth
        newPerson.address = streetAddress
        newPerson.address2 = streetAddressLine2
        newPerson.city = city
        newPerson.region = region
        newPerson.postcode = postalCode
        newPerson.country = country
        newPerson.gender = gender
        newPerson.email = email
        newPerson.phonenumber = homePhoneNumber

        do {
            try viewContext.save()
        } catch {
            print("Error saving person: \(error.localizedDescription)")
        }
    }

    private func resetForm() {
        // Clear the form fields after saving
        title = ""
        firstName = ""
        middleName = ""
        lastName = ""
        dateOfBirth = Date()
        streetAddress = ""
        streetAddressLine2 = ""
        city = ""
        region = ""
        postalCode = ""
        country = ""
        gender = "Female"
        email = ""
        homePhoneNumber = ""
    }
}


struct RegisteredPersonsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.firstname, ascending: true)]
    ) private var persons: FetchedResults<Person>

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPerson: Person?

    var body: some View {
        NavigationView {
            List {
                ForEach(persons, id: \.self) { person in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(person.title ?? "")
                                .font(.headline)
                            Text(person.firstname ?? "")
                                .font(.headline)
                            Text(person.lastname ?? "")
                                .font(.headline)
                        }
                        if let email = person.email, !email.isEmpty {
                            Text("Email: \(email)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if let phone = person.phonenumber, !phone.isEmpty {
                            Text("Phone: \(phone)")
                                .font(.subheadline)
                        }
                        if let address = person.address, !address.isEmpty {
                            Text("Address: \(address)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                    .contextMenu {
                        Button(action: {
                            selectedPerson = person
                        }) {
                            Label("Details", systemImage: "pencil")
                        }
                    }
                }
                .onDelete(perform: deletePersons)
            }
            .navigationTitle("Registered Persons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .sheet(item: $selectedPerson) { person in
                ContentView(selectedPerson: person)
            }
        }
    }

    private func deletePersons(at offsets: IndexSet) {
        offsets.map { persons[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            print("Error deleting person: \(error.localizedDescription)")
        }
    }
}

struct Country: Codable, Identifiable {
    let id = UUID()
    let name: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case name
        case code
    }
}

class CountryViewModel: ObservableObject {
    @Published var countries: [Country] = []

    init() {
        loadCountries()
    }

    func loadCountries() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            countries = try JSONDecoder().decode([Country].self, from: data)
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
