# TDBListView Component #
## Installing ##
Install the package named ExtComponents on Delphi or lazextcomponents on Lazarus. The TDBGroupview component can be erased from code.


# Using #
These lists do not edit fields. The SortType property must be set to stNone because it a TListView property not managed by the components.


## TDBListView ##
The TDBListView component can show a lot of dataset's records quickly.

The properties of this list are also in inherited TDBGroupView component.

This list is inherited from TListView component. Some parts of the component are only usefull for TDBGroupview descendant.

Needed :

**A Datasource ( propriété DataSource )** The Display Fields
**The table to show**

## Properties ##
SortColumn&nbsp;: Default sorted column. You must use p\_SetSortColumn to change the column executing. It could badly sort the list.

SortDirection property&nbsp;: SortDirection must be also change executing by p\_SetSortDirectionAsc method.


### Données ###
Datasource&nbsp;: DataSource containg field to show in the list

DataFieldsDisplay&nbsp;: Display fields to show

DataKeyUnit&nbsp;: Primary key not needed for DBListView.

DataTableUnit&nbsp;: Main display Datasource Table


### Management ###
DataRowColors&nbsp;: Showing yellow and white lines, in mc\_fonctions\_groupes functions.

DataShowAll&nbsp;: With this option the component is not usefull. The list is entirely shown at loading, so you may wait a lot.


### Asynchronous mode ###
The DBListView component can manage asynchrous ADO Dataset with ini file.