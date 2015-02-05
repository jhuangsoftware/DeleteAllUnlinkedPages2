<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2014, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Delete All Unlinked Pages 2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<link rel="stylesheet" href="css/custom.css" />
	<script type="text/javascript" src="js/jquery-1.11.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="js/delete-all-unlinked-pages-2.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script id="template-search-options" type="text/x-handlebars-template" data-container="#search-options" data-action="replace">
		<div class="alert alert-success row" >
			<form class="form-inline">
				<label class="control-label" for="inputEmail">Maximum # of Unlinked Pages</label>
				<input type="text" class="input-small" value="400" maxlength="4" size="4" id="maximumunlinkedpages">
				<button class="btn" type="button"><i class="icon-search"></i> Search</button>
			</form>
		</div>
	</script>
	<script id="template-unlinked-pages" type="text/x-handlebars-template" data-container="#unlinked-pages" data-action="replace">
		<div class="alert alert-success row" id="data-action">
			<div class="btn-group">
				<a class="btn btn-info dropdown-toggle" data-toggle="dropdown" href="#">
					Select
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="#" class="select-none">None</a></li>
					<li><a href="#" class="select-all">All</a></li>
				</ul>
			</div>
			
			<div class="btn btn-danger pull-right delete">Delete</div>
		</div>
		{{#each unlinkedpages}}
		<div class="alert row unlinked-page" id="{{guid}}" data-guid="{{guid}}">
			<div class="span5">
				<label class="checkbox">
					<input type="checkbox"> {{headline}}
				</label>
			</div>
			<div class="span5">
				{{lastmodified}}
			</div>
			<div class="span1">
				<span class="label label-important deleting"><i class="icon-cog icon-white"></i></span>
			</div>
		</div>
		{{/each}}
	</script>
	<script id="template-delete-options" type="text/x-handlebars-template" data-container="#delete-options" data-action="replace">
		<div class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-header">
				<h3 id="myModalLabel">Delete Options</h3>
			</div>
			<div class="modal-body">
				<label class="checkbox">
					<input id="forcedelete2910" name="forcedelete2910" type="checkbox" checked="checked"> Delete pages, including those containing referenced elements
				</label>
				<label class="checkbox">
					<input id="forcedelete2911" name='forcedelete2911' type="checkbox" checked="checked"> Delete pages, including those containing referenced target containers
				</label>
			</div>
			<div class="modal-footer">
				<a href="#" class="btn" data-dismiss="modal" aria-hidden="true">Close</a>
				<a href="#" class="btn btn-danger delete">Delete</a>
			</div>
		</div>
	</script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() {
			var DeleteAllUnlinkedPagesObj = new DeleteAllUnlinkedPages(RqlConnectorObj);
		});
	</script>
</head>
<body>
	<div class="container">
		<div id="search-options">
		</div>
		<div id="delete-options">
		</div>
		<div id="unlinked-pages">
			<div class="loading">
				<img src="img/loading.gif" />
			</div>
		</div>
	</div>
</body>
</html>