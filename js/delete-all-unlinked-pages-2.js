function DeleteAllUnlinkedPages(RqlConnectorObj) {
	this.RqlConnectorObj = RqlConnectorObj;
	
	this.TemplateSearchOptions = '#template-search-options';
	this.TemplateDeleteOptions = '#template-delete-options';
	this.TemplateUnlinkedPages = '#template-unlinked-pages';
	
	this.Init();
}

DeleteAllUnlinkedPages.prototype.Init = function() {
	var ThisClass = this;

	this.UpdateArea(this.TemplateSearchOptions, {});
	
	this.UpdateArea(this.TemplateDeleteOptions, {});

	var SearchOptionsContainer = $(this.TemplateSearchOptions).attr('data-container');
	
	$(SearchOptionsContainer).on('click', '.btn', function(){
		var MaxPageCount = $(SearchOptionsContainer).find('input').val();
		ThisClass.SearchUnlinkedPages(MaxPageCount);
	});
	
	$(SearchOptionsContainer).find('.btn').click();
	
	var UnlinkedPagesContainer = $(this.TemplateUnlinkedPages).attr('data-container');
	$(UnlinkedPagesContainer).on('click', '#data-action .select-none', function(){
		$(UnlinkedPagesContainer).find('input:visible').prop('checked', false);
	});
	
	$(UnlinkedPagesContainer).on('click', '#data-action .select-all', function(){
		$(UnlinkedPagesContainer).find('input:visible').prop('checked', true);
	});
	
	var DeleteOptionsContainer = $(this.TemplateDeleteOptions).attr('data-container');
	
	$(UnlinkedPagesContainer).on('click', '#data-action .delete', function(){
		if($(UnlinkedPagesContainer).find('input:visible:checked').length > 0){
			$(DeleteOptionsContainer).find('.modal').modal('show');
		}
	});
	
	$(DeleteOptionsContainer).on('click', '.delete', function(){
		var forcedelete2910 = ($(DeleteOptionsContainer).find('#forcedelete2910:checked'))?1:0;
		var forcedelete2911 = ($(DeleteOptionsContainer).find('#forcedelete2911:checked'))?1:0;
		
		$(DeleteOptionsContainer).find('.modal').modal('hide');
		
		$(UnlinkedPagesContainer).find('.unlinked-page:has(input:visible:checked)').each(function(){
			var ThisDom = $(this);
			var PageGuid = $(this).attr('data-guid');
		
			$(this).addClass('alert-danger');
			$(this).find('.deleting').show();
			$(this).find('input').hide();
			
			ThisClass.DeleteUnlinkedPage(forcedelete2910, forcedelete2911, PageGuid, function(data){
				ThisDom.remove();
			});
		});
	});
}

DeleteAllUnlinkedPages.prototype.SearchUnlinkedPages = function(MaxPageCount) {
	var ThisClass = this;
	var RqlXml = '<PAGE action="xsearch"  pagesize="' + MaxPageCount + '" orderby="changedate"><SEARCHITEMS><SEARCHITEM key="specialpages" value="unlinked" operator="eq" displayvalue=""></SEARCHITEM></SEARCHITEMS></PAGE>';
	
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var UnlinkedPages = [];
		
		$(data).find('PAGE').each(function() {
			var UnlinkedPage = {
				guid: $(this).attr('guid'),
				headline: $(this).attr('headline'),
				lastmodified: ThisClass.FormatDateObject(ThisClass.ConvertFromRedDotDate($(this).find('CHANGE').attr('date')))
			};
			
			UnlinkedPages.push(UnlinkedPage);
		});

		ThisClass.UpdateArea(ThisClass.TemplateUnlinkedPages, {unlinkedpages: UnlinkedPages});
	});
}

DeleteAllUnlinkedPages.prototype.DeleteUnlinkedPage = function(forcedelete2910, forcedelete2911, PagesGuid, CallbackFunc) {
	var RqlXml = '<PAGE action="delete" forcedelete2910="' + forcedelete2910 + '" forcedelete2911="' + forcedelete2911 + '"  guid="' + PagesGuid + '"/>';
	
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		CallbackFunc(data);
	});
}

DeleteAllUnlinkedPages.prototype.ConvertFromRedDotDate = function(ReddotDate) {
    var days = Math.floor(ReddotDate);
    var milliseconds = Math.round((ReddotDate-days)*86400000);
    var adjusted_days_in_millseconds = (days-25569) * 86400000;
    var RetDate = new Date();
    RetDate.setTime(adjusted_days_in_millseconds + milliseconds);
    var ajusted_minutes = RetDate.getTimezoneOffset();
    RetDate.setMinutes(RetDate.getMinutes() + ajusted_minutes);
  
    return RetDate;
}

DeleteAllUnlinkedPages.prototype.FormatDateObject = function(DateObj) {
	var FormatedDate = '';
	FormatedDate += DateObj.getFullYear();
	FormatedDate += '/';
	FormatedDate += DateObj.getMonth() + 1;
	FormatedDate += '/';
	FormatedDate += DateObj.getDate();
	FormatedDate += ' - ';
	FormatedDate += DateObj.toLocaleTimeString();
	
	return FormatedDate;
	
	//return DateObj.toLocaleString();
}

DeleteAllUnlinkedPages.prototype.UpdateArea = function(TemplateId, Data){
	var ContainerId = $(TemplateId).attr('data-container');
	var TemplateAction = $(TemplateId).attr('data-action');
	var Template = Handlebars.compile($(TemplateId).html());
	var TemplateData = Template(Data);

	if((TemplateAction == 'append') || (TemplateAction == 'replace'))
	{
		if (TemplateAction == 'replace') {
			$(ContainerId).empty();
		}

		$(ContainerId).append(TemplateData);
	}

	if(TemplateAction == 'prepend')
	{
		$(ContainerId).prepend(TemplateData);
	}

	if(TemplateAction == 'after')
	{
		$(ContainerId).after(TemplateData);
	}
}