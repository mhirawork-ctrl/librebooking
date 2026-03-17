<div id="{$divId|default:'reservation-created'}" class="reservationResponseMessage">
	<div class="card border-0 shadow-sm">
		<div class="card-body p-4 text-center">
			<div id="reservation-response-image" class="mb-3">
				{if $RequiresApproval}
					<i class="bi bi-flag-fill fs-1 text-warning"></i>
				{else}
					<i class="bi bi-check-lg fs-1 text-success"></i>
				{/if}
			</div>

			<div id="created-message" class="reservation-message fw-bold fs-4 mb-2">
				{translate key=$messageKey|default:"ReservationCreated"}
			</div>
			<div id="reference-number" class="text-muted mb-3">{translate key=YourReferenceNumber args=$ReferenceNumber}</div>

			<div class="rounded border bg-body-tertiary text-start p-3 mb-3">
				<div class="mb-3">
					<div class="fw-bold mb-1">{translate key=Dates}</div>
					<div class="dates small" style="max-height: 12em; overflow-y: auto;">
						{foreach from=$Instances item=instance}
							<div class="date">{format_date date=$instance->StartDate() timezone=$Timezone}</div>
						{/foreach}
					</div>
				</div>

				<div>
					<div class="fw-bold mb-1">{translate key=Resources}</div>
					<div class="resources small">
						{foreach from=$Resources item=resource}
							<div class="resource">{$resource->GetName()}</div>
						{/foreach}
					</div>
				</div>
			</div>

			{if $RequiresApproval}
				<div id="approval-message" class="alert alert-warning text-start small">{translate key=ReservationRequiresApproval}</div>
			{/if}

			<div class="reservationResponseMessage__actions d-flex flex-column flex-sm-row justify-content-center gap-2">
				<a href="reservation.php?{QueryStringKeys::REFERENCE_NUMBER}={$ReferenceNumber}" class="btn btn-primary">
					<i class="bi bi-search me-1"></i>{translate key='ViewReservation'}
				</a>
				<a href="reservation.php?{QueryStringKeys::REFERENCE_NUMBER}={$ReferenceNumber}&update=1" class="btn btn-outline-danger">
					<i class="bi bi-x-circle me-1"></i>予約を取り消す
				</a>
				<button type="button" id="btnReturnToPreviousPage" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left-circle-fill me-1"></i>{translate key='ReturnToPreviousPage'}
				</button>
			</div>

			<div class="reservationResponseMessage__next rounded border bg-body-tertiary text-start p-3 mt-3">
				<div class="fw-bold mb-2">次にできること</div>
				<div class="d-flex flex-column flex-lg-row flex-wrap gap-2">
					<a href="#" id="btnOpenMonthCalendar" class="btn btn-outline-primary">
						<i class="bi bi-calendar3 me-1"></i>月間カレンダーへ戻る
					</a>
					<a href="#" id="btnOpenScheduleView" class="btn btn-outline-primary">
						<i class="bi bi-layout-three-columns me-1"></i>時間割ビューで確認
					</a>
					<a href="#" id="btnCreateAnotherReservation" class="btn btn-outline-secondary">
						<i class="bi bi-plus-circle me-1"></i>同じ会議室で続けて予約
					</a>
				</div>
			</div>
		</div>
	</div>
</div>
