{include file='globalheader.tpl'}

<div id="page-dashboard" class="dashboard-home">
	<div id="dashboardList" class="dashboard-home__reservations">
		{foreach from=$items item=dashboardItem}
			<div>{$dashboardItem->PageLoad()}</div>
		{/foreach}
	</div>

	<section class="dashboard-home__schedule card border-0">
		<div class="dashboard-home__schedule-header">
			<div></div>
		</div>
		<div class="dashboard-home__schedule-frame-wrap">
			<iframe
				id="dashboardScheduleFrame"
				class="dashboard-home__schedule-frame"
				src="{Pages::SCHEDULE}?{Pages::HOME_OVERVIEW_QUERY_KEY}={Pages::HOME_OVERVIEW_QUERY_VALUE}&embed=1"
				title="会議室予約の時間割ビュー"
				loading="lazy"></iframe>
		</div>
	</section>

	{include file="javascript-includes.tpl"}

	{jsfile src="dashboard.js"}
	{jsfile src="resourcePopup.js"}
	{jsfile src="ajax-helpers.js"}

	<script type="text/javascript">
		$(document).ready(function() {

			var dashboardOpts = {
				reservationUrl: "{Pages::RESERVATION}?{QueryStringKeys::REFERENCE_NUMBER}=",
				summaryPopupUrl: "ajax/respopup.php",
				scriptUrl: '{$ScriptUrl}'
			};

			var dashboard = new Dashboard(dashboardOpts);
			dashboard.init();

			var scheduleFrame = document.getElementById('dashboardScheduleFrame');
			if (scheduleFrame) {
				var syncScheduleFrame = function() {
					try {
						var frameDocument = scheduleFrame.contentDocument || scheduleFrame.contentWindow.document;
						if (!frameDocument) {
							return;
						}

						frameDocument.body.style.background = 'transparent';
						frameDocument.body.style.padding = '0';
						frameDocument.body.style.margin = '0';

						var page = frameDocument.getElementById('page-schedule');
						if (page) {
							page.style.padding = '0 0 1rem';
						}

						var contentHeight = Math.max(
							frameDocument.body.scrollHeight,
							frameDocument.documentElement.scrollHeight,
							1200
						);
						scheduleFrame.style.height = contentHeight + 'px';
					} catch (error) {
						scheduleFrame.style.minHeight = '1200px';
					}
				};

				scheduleFrame.addEventListener('load', function() {
					syncScheduleFrame();

					try {
						var frameDocument = scheduleFrame.contentDocument || scheduleFrame.contentWindow.document;
						var observer = new MutationObserver(function() {
							syncScheduleFrame();
						});
						observer.observe(frameDocument.body, {
							childList: true,
							subtree: true,
							attributes: true
						});
					} catch (error) {
					}
				});
			}
		});
	</script>
</div>

<div id="wait-box" class="modal fade" aria-labelledby="update-boxLabel" data-bs-backdrop="static" aria-hidden="true">
	<div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
			<div class="modal-body">
				<div id="creatingNotification">
					{include file='wait-box.tpl' translateKey='Working'}
				</div>
				<div id="result" class="text-center"></div>
			</div>
		</div>
	</div>
</div>
{include file='globalfooter.tpl'}
