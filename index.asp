<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN'
   'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html>
<head>
	<meta http-equiv='expires' content='-1' />
	<meta http-equiv='content-type' content='text/html; charset=utf-8' />
	<meta name='copyright' content='2013, Web Site Management' />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Delete All Unlinked Pages 2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type='text/css'>
		body
		{
			padding: 10px;
		}
	</style>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);

		var UnlinkedPageGuidArray;
		
		var forcedelete2910;
		var forcedelete2911;
		
		function setDeleteOptions()
		{
			// save delete settings as global var
			// use global var instead of pass as param in recurisive function because less memory required
			forcedelete2910 = ($('#forcedelete2910').is(':checked'))?1:0;
			forcedelete2911 = ($('#forcedelete2911').is(':checked'))?1:0;
			
			$('#forcedelete2910').prop('disabled', true);
			$('#forcedelete2911').prop('disabled', true);
		}
		
		function searchUnlinkedPages()
		{
			$('#processing').modal('show');
			// maximum unlinked pages to search for
			var MaxUnlinked = $('#maximumunlinkedpages').val();
			
			// load all unlinked pages
			var strRQLXML = '<PAGE action="xsearch"  pagesize="' + MaxUnlinked + '" orderby="changedate"><SEARCHITEMS><SEARCHITEM key="specialpages" value="unlinked" operator="eq" displayvalue=""></SEARCHITEM></SEARCHITEMS></PAGE>';

			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				UnlinkedPageGuidArray = new Array();
				
				$(data).find('PAGE').each(function() {
					var UnlinkedPage = new Object;
					UnlinkedPage.guid = $(this).attr('guid');
					UnlinkedPage.headline = $(this).attr('headline');
					
					UnlinkedPage.reddotdate = $(this).find('CHANGE').attr('date');
					
					UnlinkedPageGuidArray.push(UnlinkedPage);
				});
				
				$('#statusarea').text(UnlinkedPageGuidArray.length + ' unlinked pages found.');

				$('#processing').modal('hide');
				
				$('#delete-dialog').modal('show');
			});
		}
		
		function deletePage(InputArray)
		{
			var ToBeProcessItem = InputArray.shift();

			if(ToBeProcessItem == null)
			{
				$('#statusarea').text('All unlinked pages deleted.');
			}
			else
			{
				// change status text
				var DisplayText = '';
				DisplayText += InputArray.length + ' unlinked pages remaining.';
				DisplayText += '<br />';
				DisplayText += 'Deleting ' + ToBeProcessItem.headline;
				DisplayText += '<br />';
				DisplayText += 'Last changed: ' + ConvertFromRedDotDate(ToBeProcessItem.reddotdate);

				$('#statusarea').html(DisplayText);

				var strRQLXML = '<PAGE action="delete" forcedelete2910="' + forcedelete2910 + '" forcedelete2911="' + forcedelete2911 + '"  guid="' + ToBeProcessItem.guid + '"/>';
				RqlConnectorObj.SendRql(strRQLXML, false, function(data){
					//alert('Data Loaded: ' + data);
					deletePage(InputArray);
				});
			}
		}
		
		// server saves in UNC time
		var ajusted_milliseconds = new Date().getTimezoneOffset()*60*1000; // x millseconds away from jan 1 1970 UTC
		function ConvertToRedDotDate(MMDDYYYY)
		{
			var DateTimeObj = new Date(MMDDYYYY);
			var RedDotDate = Math.floor((DateTimeObj.getTime() + ajusted_milliseconds) / 86400000) + 25569;
			return RedDotDate;
		}

		function ConvertFromRedDotDate(reddotDate)
		{
			var days = Math.floor(reddotDate);
			var milliseconds = Math.round((reddotDate-days)*86400000);
			var adjusted_days_in_millseconds = (days-25569) * 86400000;
			var RetDate = new Date();
			RetDate.setTime(adjusted_days_in_millseconds + milliseconds + ajusted_milliseconds);
			return RetDate.toDateString();
		}
	</script>
</head>
<body>
	<div class="form-horizontal">
		<div class="navbar navbar-inverse">
			<div class="navbar-inner">
				<span class="brand">Search Options</span>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="new-page-owner">Maximum # of Unlinked Pages</label>
			<div class="controls">
				<input type="text" value="400" maxlength="4" size="4" id="maximumunlinkedpages" />
			</div>
		</div>
		<div class="form-actions">
			<button class="btn btn-success pull-right" onclick="searchUnlinkedPages();">Search</button>
		</div>
	</div>
	
	<div id="delete-dialog" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Delete Options</h3>
		</div>
		<div class="modal-body">
			<div class="alert alert-info alert-block" id="statusarea">
			</div>
			<label class="checkbox">
				<input id="forcedelete2910" name="forcedelete2910" type="checkbox" checked="checked"> Delete pages, including those containing referenced elements
			</label>
			<label class="checkbox">
				<input id="forcedelete2911" name='forcedelete2911' type="checkbox" checked="checked"> Delete pages, including those containing referenced target containers
			</label>
		</div>
		<div class="modal-footer">
			<a href="#" class="btn" onclick="self.close()">Close</a>
			<a href="#" class="btn btn-danger" onclick="$(this).hide();setDeleteOptions();deletePage(UnlinkedPageGuidArray);">Delete</a>
		</div>
	</div>
	
	<div id="processing" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Processing</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
</body>
</html>