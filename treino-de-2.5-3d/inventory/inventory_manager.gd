extends Node

var list = []

enum Items {
	ITEM1,
	ITEM2,
	ITEM3,
}

func add_item(item: Items):
	list.append(item)
	print("item anadido, lista completa: ",list)
	
