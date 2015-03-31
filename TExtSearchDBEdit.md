# TExtSearchEdits Components #
## TExtSearchDBEdit and TExtSearchEdit ##
The TExtSearchDBEdit and TExtSearchEdit Components can fill a cloned Field, like a city in a command, searching the end of word in SearchSource.


It owns, like the components included in this package, a Focus and Edit Color, etc.


### To fill ###

Fill SearchSource with your Datasource witch Search, with optional SearchList for Popup.

Fill SearchDisplay with the Field whose Search from SearchSource.


OnLocate is called when a record is found in SearchEdit, if this word is in SearchSource.

OnSet is called when modifying the Edit Datasource.