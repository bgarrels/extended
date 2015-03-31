# TDBGroupView Component #
## TDBGroupView ##


The TDBGroupview component car manage a 1-N,N-N or customized relation-ships.

Needed :

**Two TDBGroupView components** A main and secondary list (DataListPrimary property)
**Fields and Datasource to show** Primary key and secondary key fields
**Table saving groups** 2 or 4 transfer arrowed buttons, included in package
**A record button, also included** A cancel button, also included
**The lists' refresh Datasource (DatasourceOwner property)**

## Properties ##
SortColumn&nbsp;: Default sorted column. You must use p\_SetSortColumn to change the column executing. It could badly sort the list. No sort of TGroupview executing is recomanded.

SortDirection property&nbsp;: SortDirection must be also change executing by p\_SetSortDirectionAsc method.


### Buttons ###
ButtonCancel&nbsp;: Cancel linking or unlinking

ButtonRecord&nbsp;: Records changes

ButtonBasket&nbsp;: With 1-N relation-ships.

ButtonIn&nbsp;: Selection transfer in

ButtonOut&nbsp;: Selection transfer out

ButtonTotalIn&nbsp;: All records or filtered records transfer in

ButtonTotalOut&nbsp;: All records or filtered records transfer out


### Datasource ###
Datasource&nbsp;: It can be unset. DataSource linked to a Query contained the fields to show in list. To customize : If it is an include list, group table is needed.

DataSourceQuery et DataSourceQuery2 : It can be unset. To set if Datasource is not a Query.

DataFieldsDisplay&nbsp;: Display fields

DataKeyUnit&nbsp;: Primary key of units shown. For the moment one field can be set.

DataTableUnit&nbsp;: Units table.

DataFieldUnit&nbsp;: Secondary key of shown units, or units key if 1-N relation-ships.

DataFieldGroup&nbsp;: Secondary key of groups, or group key if 1-N relation-ships.

DataTableGroup&nbsp;: Relations-ships table. If it does not exist put unit table.

DataAllFiltered et DBAllFilter&nbsp;: native SQL filter.

DataRecordValue&nbsp;: In a no DatasourceOwner management. Each list must own its DBRecordValue on DataSourceFieldGroup. When we set it each added element is setted wirth first element of the separated commas list. If there is nothing on DBRecordValue so NULL is set in the list. If there is no DBRecordValue at all, the management is not activated.

### DatasourceOwner ###
DatasourceOwner&nbsp;: This Datasoource permits to refresh the lists from a main datasource.

DataKeyOwner&nbsp;: Datasource key. It will do the link and queries.

DataSourceOwnerTable&nbsp;: Group Table

### Management ###
DataImgDelete&nbsp;: Main deleting image. To use images set StateImages or Images.

DataImgInsert&nbsp;: Main adding image. To use images set StateImages or Images.

DataListPrimary&nbsp;: True if main list, so include list.

DataOppositeList&nbsp;: Opposite linked list. DataListPrimary must be inverted.

DataRowColors&nbsp;: Showing yellow and white lines, in mc\_fonctions\_groupes functions.

DataShowAll&nbsp;: With this option the component is not usefull. The list is entirely shown at loading, so you may wait a lot.

### DBGroupView  events ###
The OnClick events of transfer buttons are executed after transfer.


Somme events occure in main DBGroupView.The old OnClick events are launched before these events.


OnDataRecorded&nbsp;: Occures when recording.

DBOnCanceled&nbsp;: Cancel recording event.

DBOnRecordError&nbsp;: Recording error event.

OnDataAllQuery : Occures instead every items are transfered. So set Dataset and DBButtonOption property instead DBButtonRecord property. So customizet the OnClick Button event.

DBOnFilter&nbsp;: Occures instead filtering. See OnDataAllQuery.

BasketSQLWhereAll&nbsp;: Basket customize event, on 1-N relation-ships.


### Update queries ###
Use OnDataRecorded event to update data.

For basket management create the query with fb\_buildWhereBasket function (see before).

For group management use the fb\_TableauVersSQL function in fonctions\_variant (See after).


### External Functions ###
#### fb\_buildWhereBasket Function ####
For a 1-N group relation-ships.

Send True if query contains anything.

Paramètres&nbsp;: aalv\_Primary&nbsp;: include list for update

as\_Result: Where clause of query

ab\_GetNull : True if Null records are found in include list

ab\_GetCurrent&nbsp;: catch current record with query


#### fb\_TableauVersSQL Function ####
For a N-N group relation-ships.

If gb\_AllSelect is False on a list :

**Use excluding gstl\_KeysListOut from exclude list to update the relation-ships.** Use including gstl\_KeysListOut from include list to update the relation-ships.

If gb\_AllSelect is True on a list&nbsp;:

**Set gb\_ListTotal to True and invert the lists.**

Send True if the SQL text contains the records.

Parameters&nbsp;:as\_TexteAjoute: Recordrs séparated by comma

at\_Liste: Variant array containing records to update

alst\_Cle: Put Nil

### Finishing the customize ###
Set to your Datasource the customized request.


For the customized relation-ships and records sets set OnDataAllQuery (every records transfer event) and ButtonOption property instead of ButtonRecord.


For 1-N relation-ships use BasketSQLWhereAll.

This event customizes the request,

Paramètres&nbsp;: Sender&nbsp;: The current liste

Result: Where clause of request

GetNullRecords : True if there is Null records in excluding list

GetCurrentGroup: Catch current record