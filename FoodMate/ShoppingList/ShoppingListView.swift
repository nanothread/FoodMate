//
//  ShoppingListView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct ShoppingListView: View {
    @FetchRequest(entity: ShoppingItem.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: true)],
                  predicate: nil,
                  animation: .spring())
    private var items: FetchedResults<ShoppingItem>
    
    @Environment(\.managedObjectContext) private var context
    
    @State private var newActiveItemName: String = ""
    @State private var newCompletedItemName: String = ""
    
    var activeItems: [ShoppingItem] {
        items.filter { $0.status == .pending }
    }
    
    var completedItems: [ShoppingItem] {
        items.filter { $0.status == .completed }
    }
    
    func dateBinding(for item: ShoppingItem) -> Binding<Date> {
        Binding(get: {
            item.expiryDate ?? Date()
        }, set: { date in
            if Calendar.current.isDateInToday(date) {
                item.expiryDate = nil
            } else {
                item.expiryDate = date
            }
            
            saveContext(actionDescription: "update expiry date")
        })
    }
    
    func checkBinding(for item: ShoppingItem) -> Binding<Bool> {
        Binding(get: {
            item.status == .completed
        }, set: { isChecked in
            item.status = isChecked ? .completed : .pending
            saveContext(actionDescription: "toggle item status")
        })
    }
    
    func createItem(name: Binding<String>, status: ShoppingItemStatus) {
        defer {
            name.wrappedValue = ""
        }
        
        guard !name.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        _ = ShoppingItem(context: context, name: name.wrappedValue, status: status)
        saveContext(actionDescription: "create item")
    }
    
    func deleteItems(from items: [ShoppingItem], at indices: IndexSet) {
        indices.map { items[$0] }.forEach(context.delete)
        saveContext(actionDescription: "delete active items")
    }
    
    func saveContext(actionDescription: String) {
        do {
            try context.save()
        } catch {
            Logger.coreData.error("ShoppingListView failed to \(actionDescription): \(error.localizedDescription)")
        }
    }
    
    func toggleStatus(of item: ShoppingItem) {
        item.status = item.status == .pending ? .completed : .pending
        saveContext(actionDescription: "toggle status of \(item.name)")
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("To Buy")) {
                    ForEach(activeItems) { item in
                        ShoppingItemRow(
                            name: item.name,
                            date: dateBinding(for: item),
                            isChecked: checkBinding(for: item)
                        )
                    }
                    .onDelete { deleteItems(from: activeItems, at: $0) }
                    
                    TextField("New Item...", text: $newActiveItemName, onCommit: {
                        createItem(name: $newActiveItemName, status: .pending)
                    })
                }
                
                Section(header: Text("To Sort")) {
                    ForEach(completedItems) { item in
                        ShoppingItemRow(
                            name: item.name,
                            date: dateBinding(for: item),
                            isChecked: checkBinding(for: item),
                            onLocationTapped: { _ in }
                        )
                    }
                    .onDelete { deleteItems(from: completedItems, at: $0) }
                    
                    TextField("New Item...", text: $newCompletedItemName, onCommit: {
                        createItem(name: $newCompletedItemName, status: .completed)
                    })
                }
            }
            .navigationTitle("Shopping List")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
