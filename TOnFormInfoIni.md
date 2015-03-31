##### TOnFormInfoIni Component #####
February the 24th of 2003 version.
Important changes on December of 2011.


## Description ##
'TOnFormInfoIni' is a component which saves forms data in an INI file. It saves some specified components data when we quit the software. So we find data in forms when we restart the software.


To get this component into components's panel, launch ‘ExtComponents.dpk’ on Delphi ou ‘lazextcomponents.lpk' on Lazarus, compile and install.

The 'TOnFormInfoIni' component is on 'ExtInvisible' page into components's panel.

For the component to be functionnal, the Main Form must inherit from FormMainIni.

## Properties ##


SauveEditObjets

Parameters' list de paramètres which saves some TEdit, TComboBox, TCurrentEdit, TDateEdit, TDateTimePicker, TDirectoryEdit, TFileNameEdit, TMemo, TListBox, TRichEdit, TSpinEdit. TEdit, TCheck, TComboValue, TComboBox, TColorCombo,TCurrencyEdit,TDateEdit, TDateTimePicker,
TDirectoryEdit, TFileNameEdit, TGrid,TListBox, TListView, TMemo, TPageControl, TPopup, TRadio, TRadioGroup, TRichEdit,TSpinEdit,
> TVirtualTrees

Default value : FALSE

## SaveForm ##

**sfSavePosForm** : Saves the positions  of Form contained of TOnFormInfoIni.

Default value : FALSE

**sfSameMonitor** : Saves the position of owner Form on the screen of Main Form.

Default value : FALSE

**sfSaveSizes** : Saves the positions  of TSplitters contained in TOnFormInfoIni form.

Default value : FALSE


# Using and technical informations #


Place the component into each software form, where you want to save not DB components. So select the types of components you want to save.
On each show or create of form, the component reads ini file.
If the value does not exists the component create it in Application Directory's ini file :

**user\_config.ini**

Each form will have its section of TOnFormInfoIni in ini file, named by the form name.In each form section, there is a list of components contained in ths window. The section is erased on each form ini writing.

The ini si written on each OnFormInfoIni's form closed.

If the executable is in write protected directory, The ini will be put in user or root config.


## Converters ##

Here is a [little conversion of sfSavePos to sfSavePos,sfSaveSize](http://www.lazarus-components.org/downloads/ConvertSaveSize.zip).
Here is a [project to convert old TOnFormInfoIni](http://www.lazarus-components.org/downloads/Projects-with-sources-and-components/Programming/For-Lazarus/Traducing-TOnFormInfoIni-Projects-on-Extended/).