//
//  ShoppingListView.swift
//  FoodMate
//
//  Created by Andrew Glen on 03/10/2020.
//

import SwiftUI

struct ShoppingListView: View {
    @FetchRequest(entity: ShoppingItem.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: true)])
    private var items: FetchedResults<ShoppingItem>
    
    @Environment(\.managedObjectContext) private var context
    
    @State private var newItemName: String = ""
    
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
            print("Setting expiry date for", item.name)
            if Calendar.current.isDateInToday(date) {
                item.expiryDate = nil
            } else {
                item.expiryDate = date
            }
        })
    }
    
    func createItem() {
        defer {
            newItemName = ""
        }
        
        guard !newItemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        _ = ShoppingItem(context: context, name: newItemName)
        
        do {
            try context.save()
        } catch {
            Logger.coreData.error("ShoppingListView failed to create item: \(error.localizedDescription)")
        }
    }
    
    func deleteActiveItems(at indices: IndexSet) {
        indices.map { activeItems[$0] }.forEach(context.delete)
        
        do {
            try context.save()
        } catch {
            Logger.coreData.error("ShoppingListView failed to delete active items: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("To Buy")) {
                    ForEach(activeItems) { item in
                        ActiveShoppingItemView(name: item.name, date: dateBinding(for: item))
                    }
                    .onDelete(perform: deleteActiveItems)
                    
                    TextField("New Item...", text: $newItemName, onCommit: createItem)
                }
                
                Section(header: Text("To Sort")) {
                    
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
