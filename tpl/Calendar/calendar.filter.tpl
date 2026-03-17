<div class="calendar-filter card border-0 shadow-sm">
    <div class="card-body">
        <div id="filter">
            {if isset($GroupName) && $GroupName}
                <div class="calendar-filter__summary text-center">
                    <div class="calendar-filter__eyebrow">Reservation Board</div>
                    <div class="groupName fw-bold fs-4">{$GroupName}</div>
                    <div class="calendar-filter__hint">空き状況を見ながら、日付をクリックして予約作成に進めます。</div>
                </div>
            {else}
                <div class="calendar-filter__row">
                    <div class="calendar-filter__intro">
                        <div class="calendar-filter__eyebrow">Reservation Board</div>
                        <div class="calendar-filter__title">会議室の月間カレンダー</div>
                        <div class="calendar-filter__hint">会議室を切り替えながら、空き日程と予約状況をひと目で確認できます。</div>
                    </div>
                    <div class="calendar-filter__controls">
                        <div class="calendar-filter__control">
                            <div>{indicator id=loadingIndicator}</div>
                            <label class="fw-bold me-2" for="calendarFilter">{translate key="ChangeCalendar"}</label>
                            <select id="calendarFilter" class="form-select w-auto">
                                {foreach from=$filters->GetFilters() item=filter}
                                    <option value="s{$filter->Id()}" class="schedule" {if $filter->Selected()}selected="selected" {/if}>
                                        {$filter->Name()}</option>
                                    {foreach from=$filter->GetFilters() item=subfilter}
                                        <option value="r{$subfilter->Id()}" class="resource" {if $subfilter->Selected()}selected="selected"
                                            {/if}>{$subfilter->Name()}</option>
                                    {/foreach}
                                {/foreach}
                            </select>
                        </div>
                        <a href="#" id="showResourceGroups" class="calendar-filter__groups-link">{translate key=ResourceGroups}</a>
                    </div>
                </div>
            {/if}
        </div>
    </div>

    <div class="calendar-filter__overview">
        <div class="calendar-filter__stat">
            <div class="calendar-filter__stat-label">表示中の会議室</div>
            <div class="calendar-filter__stat-value" id="calendarCurrentTarget">{if isset($GroupName) && $GroupName}{$GroupName}{else}読み込み中{/if}</div>
        </div>
        <div class="calendar-filter__stat">
            <div class="calendar-filter__stat-label">表示期間</div>
            <div class="calendar-filter__stat-value" id="calendarCurrentRange">読み込み中</div>
        </div>
        <div class="calendar-filter__stat">
            <div class="calendar-filter__stat-label">表示中の予約件数</div>
            <div class="calendar-filter__stat-value" id="calendarVisibleCount">0件</div>
        </div>
        <div class="calendar-filter__actions">
            <a href="schedule.php" id="calendarOpenSchedule" class="calendar-filter__action">時間割ビューで詳しく見る</a>
            <a href="#" id="calendarCreateShortcut" class="calendar-filter__action calendar-filter__action--primary calendar-filter__action--disabled" aria-disabled="true">会議室を選ぶと直接予約できます</a>
            <div class="calendar-filter__microcopy">月表示で全体を見て、細かな時間調整は時間割ビューで確認できます。</div>
        </div>
    </div>

    <div id="resourceGroupsContainer" class="bg-white border rounded pt-2">
        <div id="resourceGroups"></div>
    </div>

    {if false}
        <div class="d-flex justify-content-center align-items-center my-3">
            <div class="input-group me-3">
                <label class="input-group-text fw-bold" for="ownerFilter">{translate key=Owner}</label>
                <input {formname key=USER_ID} id="ownerId" type="hidden" value="{$OwnerId}" />
                <input type='search' id='ownerFilter' class="form-control input-sm search" {formname key=OWNER_TEXT}
                    value="{$OwnerText}" />
            </div>
            {if $AllowParticipation}
                <div class="input-group me-3">
                    <label class="input-group-text fw-bold" for="participantFilter">{translate key=Participant}</label>
                    <input {formname key=PARTICIPANT_ID} id="participantId" type="hidden" value="{$ParticipantId}" /> <input
                        type='search' id='participantFilter' class="form-control input-sm search"
                        {formname key=PARTICIPANT_TEXT} value="{$ParticipantText}" />
                </div>
            {/if}
            <div class="">
                <button id="clearUserFilter" class="btn btn-outline-secondary">{translate key=Reset}</button>
            </div>
        </div>
    {/if}

</div>

<script type="text/javascript">
    $(function() {
        $('#calendarFilter').select2();
    });
</script>
