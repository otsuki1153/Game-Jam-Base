extends Node

var list = []
var power_ups = []
signal item_added(Items)
enum Items {
	ITEM1,
	ITEM2,
	ITEM3,
}


func add_item(item: Items):
	list.append(item)
	print("item anadido, lista completa: ",list)
	item_added.emit(item)
	
