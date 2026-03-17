{block name="header"}
    {include file='globalheader.tpl' cssFiles='css/schedule.css' printCssFiles='css/reservation.print.css'}
{/block}

{function name="displayResource"}
    <div class="resourceName rounded-1 m-1 p-1 {if !$resource->GetColor()}text-success bg-success bg-opacity-10" {else}"
    style="background-color:{$resource->GetColor()};color:{$resource->GetTextColor()}" {/if}>
    <span class="resourceDetails" data-resourceId="{$resource->GetId()}">{$resource->Name}</span>
    {if $resource->GetRequiresApproval()}<span class="bi bi-lock-fill" data-bs-toggle="tooltip"
        data-bs-title="approval"></span>{/if}
    {if $resource->IsCheckInEnabled()}<i class="bi bi-box-arrow-in-right" data-bs-toggle="tooltip"
        data-bs-title="checkin"></i>{/if}
    {if $resource->IsAutoReleased()}<i class="bi bi-clock-history" data-bs-toggle="tooltip" data-bs-title="autorelease"
        data-autorelease="{$resource->GetAutoReleaseMinutes()}"></i>{/if}
</div>
{/function}

<div id="page-reservation">
    <div id="reservation-box" class="container-fluid px-0">
        <form id="form-reservation" method="post" enctype="multipart/form-data" role="form">
            <div class="row g-3 my-3">
                <div class="col-xl-9 reservation-main">
                    <div class="card shadow-sm border-0 mb-3">
                        <div class="card-body p-3 p-lg-4">
                            <div class="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
                                <div class="reservationHeader">
                                    <div class="text-uppercase text-muted small fw-bold">予約フォーム</div>
                                    <h3 class="mb-1">{block name=reservationHeader}{translate key="CreateReservationHeading"}{/block}</h3>
                                    <p class="mb-0 text-muted small">用途、日時、会議室、連絡事項の順に入力できる会議室予約用フォームです。</p>
                                </div>
                                <div class="d-flex flex-wrap gap-2 justify-content-lg-end">
                                    <button type="button" class="btn btn-sm btn-outline-secondary"
                                        onclick="window.location='{$ReturnUrl}'">
                                        <i class="bi bi-arrow-left-circle-fill"></i>
                                        <span>{translate key='Cancel'}</span>
                                    </button>
                                    {block name="submitButtons"}
                                    <button type="button" class="btn btn-sm btn-primary save create btnCreate">
                                        <i class="bi bi-check-circle"></i>
                                        {translate key='Create'}
                                    </button>
                                    {/block}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 mb-3">
                        <div class="card-header bg-body-tertiary border-0 py-3">
                            <div class="fw-bold">基本情報</div>
                            <div class="small text-muted">部屋使用用途と予約者情報をここで入力します。</div>
                        </div>
                        <div class="card-body p-3 p-lg-4">
                            <div class="row g-3">
                                <div class="form-group col-12">
                                    <div class="rounded border bg-body-tertiary p-3 h-100">
                                        <div class="d-flex align-items-center justify-content-between gap-2 flex-wrap">
                                            <label class="fw-bold mb-0" for="userName">研究室名</label>
                                            {if $CanChangeUser}
                                            <a href="#" id="showChangeUsers" class="link-primary">{translate key=Change} <i
                                                    class="bi bi-person-fill"></i></a>
                                            {/if}
                                        </div>
                                        <div class="mt-2">
                                            {if $ShowUserDetails && $ShowReservationDetails}
                                            <a href="#" id="userName" data-userid="{$UserId}" class="link-primary">{$ReservationUserName}</a>
                                            {else}
                                            {translate key=Private}
                                            {/if}
                                        </div>
                                        <input id="userId" type="hidden" {formname key=USER_ID} value="{$UserId}" />
                                        <div id="availableCredits" class="mt-2{if !$CreditsEnabled} d-none{/if}">
                                            <span class="small text-muted">{translate key=AvailableCredits}</span>
                                            <span id="availableCreditsCount" class="fw-bold">{$CurrentUserCredits}</span>
                                            <span class="text-muted">|</span>
                                            <span class="small text-muted">{translate key=CreditsRequired}</span>
                                            <span id="requiredCreditsCount">
                                                <span class="spinner-border spinner-border-sm" role="status"></span></span>
                                            <span id="creditCost" class="fw-bold"></span>
                                        </div>

                                        <div class="mt-3" id="changeUsers" style="display: none;">
                                            <div class="form-group d-flex align-items-center gap-1 flex-wrap">
                                                <label for="changeUserAutocomplete" class="visually-hidden">{translate key=User}</label>
                                                <input type="text" id="changeUserAutocomplete"
                                                    class="form-control form-control-sm user-search" />
                                                <span class="vr m-2 d-none d-sm-inline-block"></span>
                                                <a href="#" id="promptForChangeUsers" class="link-primary">
                                                    <i class="bi bi-people-fill"></i>
                                                    {translate key='AllUsers'}
                                                </a>
                                            </div>
                                        </div>
                                    </div>

                                    {if $CanChangeUser}
                                    <div class="modal fade" id="changeUserDialog" tabindex="-1" role="dialog"
                                        aria-labelledby="usersModalLabel" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-scrollable">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title" id="usersModalLabel">{translate key=ChangeUser}
                                                    </h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                        aria-hidden="true"></button>
                                                </div>
                                                <div class="modal-body">
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-outline-secondary"
                                                        data-bs-dismiss="modal">{translate key='Cancel'}</button>
                                                    <button type="button" class="btn btn-primary">{translate key='Done'}</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    {/if}
                                </div>

                                <div class="form-group col-12 col-lg-6">
                                    <label class="fw-bold mb-1" for="reservationPurpose">用途 <i
                                            class="bi bi-asterisk text-danger align-top text-small"></i></label>
                                    <select id="reservationPurpose" class="form-select" {formname key=RESERVATION_PURPOSE}>
                                        <option value="">選択してください</option>
                                        <option value="学生指導（講義・ゼミ含む）">学生指導（講義・ゼミ含む）</option>
                                        <option value="講演会・研究会">講演会・研究会</option>
                                        <option value="学内会議・打ち合わせ">学内会議・打ち合わせ</option>
                                        <option value="外部来客">外部来客</option>
                                        <option value="学生個人利用">学生個人利用</option>
                                        <option value="その他">その他</option>
                                    </select>
                                </div>

                                <div class="form-group col-12 col-lg-3">
                                    <label class="fw-bold mb-1" for="reservationContactName">予約者氏名 <i
                                            class="bi bi-asterisk text-danger align-top text-small"></i></label>
                                    <input id="reservationContactName" type="text" class="form-control"
                                        {formname key=RESERVATION_CONTACT_NAME} value="" maxlength="100" />
                                </div>

                                <div class="form-group col-12 col-lg-3">
                                    <label class="fw-bold mb-1" for="reservationContactExtension">内線番号 <i
                                            class="bi bi-asterisk text-danger align-top text-small"></i></label>
                                    <input id="reservationContactExtension" type="text" class="form-control"
                                        {formname key=RESERVATION_CONTACT_EXTENSION} value="" maxlength="30"
                                        list="reservationPhoneOptions" />
                                    <div class="form-text">プロフィールに登録した候補から選択できます。直接入力も可能です。</div>
                                    <datalist id="reservationPhoneOptions">
                                        {foreach from=$ReservationPhoneOptions item=phoneOption}
                                        <option value="{$phoneOption|escape}"></option>
                                        {/foreach}
                                    </datalist>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 mb-3">
                        <div class="card-header bg-body-tertiary border-0 py-3">
                            <div class="fw-bold">日時</div>
                            <div class="small text-muted">開始・終了と繰り返し設定をまとめて確認します。</div>
                        </div>
                        <div class="card-body p-3 p-lg-4">
                            <div class="reservationDates">
                                <div class="d-flex flex-wrap align-items-start gap-3">
                                    <div class="form-group d-flex align-items-center flex-wrap gap-2">
                                        <label for="BeginDate" class="reservationDate fw-bold mb-0">{translate key='BeginDate'}</label>
                                        <input type="text" id="BeginDate"
                                            class="form-control form-control-sm d-inline-block w-auto{if $LockPeriods} no-show{/if}"
                                            {formname key=BEGIN_DATE} />
                                        <select id="BeginPeriod" {formname key=BEGIN_PERIOD}
                                            class="form-select form-select-sm w-auto timeinput{if $LockPeriods} no-show{/if}"
                                            title="Begin time">
                                            {foreach from=$StartPeriods item=period}
                                            {if $period->IsReservable()}
                                            {assign var='selected' value=''}
                                            {if $period eq $SelectedStart}
                                            {assign var='selected' value=' selected="selected"'}
                                            {assign var='startPeriod' value=$period}
                                            {/if}
                                            <option value="{$period->Begin()}" {$selected}>{$period->Label()}</option>
                                            {/if}
                                            {/foreach}
                                        </select>
                                        {if $LockPeriods}{formatdate date=$StartDate} {$startPeriod->Label()}{/if}
                                    </div>

                                    <div class="form-group d-flex align-items-center flex-wrap gap-2">
                                        <label for="EndDate"
                                            class="reservationDate fw-bold mb-0">{translate key='EndDate'}</label>
                                        <input type="text" id="EndDate"
                                            class="form-control form-control-sm d-inline-block w-auto{if $LockPeriods} no-show{/if}"
                                            {formname key=END_DATE} />
                                        <select id="EndPeriod" {formname key=END_PERIOD}
                                            class="form-select form-select-sm w-auto timeinput{if $LockPeriods} no-show{/if}"
                                            title="End time">
                                            {foreach from=$EndPeriods item=period name=endPeriods}
                                            {if $period->IsReservable()}
                                            {assign var='selected' value=''}
                                            {if $period eq $SelectedEnd}
                                            {assign var='selected' value=' selected="selected"'}
                                            {assign var='endPeriod' value=$period}
                                            {/if}
                                            <option value="{$period->End()}" {$selected}>{$period->LabelEnd()}</option>
                                            {/if}
                                            {/foreach}
                                        </select>
                                        {if $LockPeriods}{formatdate date=$EndDate} {$endPeriod->LabelEnd()}{/if}
                                    </div>

                                    <div class="reservationLength rounded border bg-body-tertiary px-3 py-2">
                                        <div class="small text-muted">所要時間</div>
                                        <span class="durationText fw-bold">
                                            <span id="durationDays">0</span> {translate key=days}
                                            <span id="durationHours">0</span> {translate key=hours}
                                            <span id="durationMinutes">0</span> {translate key=minutes}
                                        </span>
                                    </div>

                                </div>

                                {if !$HideRecurrence}
                                <div class="pt-3">{$HideRecurrence}
                                    {control type="RecurrenceControl" RepeatTerminationDate=$RepeatTerminationDate}
                                </div>
                                {/if}
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 mb-3">
                        <div class="card-header bg-body-tertiary border-0 py-3">
                            <div class="fw-bold">会議室</div>
                            <div class="small text-muted">利用する会議室を選択します。</div>
                        </div>
                        <div class="card-body p-3 p-lg-4">
                            <div class="reservationResources col-12" id="reservation-resources">
                                <div class="rounded border bg-body-tertiary p-3 h-100">
                                    <div class="d-flex align-items-center justify-content-between gap-2 flex-wrap mb-3">
                                        <label class="fw-bold mb-0">{translate key="Resources"}</label>
                                        {if $ShowAdditionalResources}
                                        <a id="btnAddResources" href="#" class="link-primary" data-bs-toggle="modal"
                                            data-bs-target="#dialogResourceGroups">変更・追加 <span
                                                class="bi bi-plus-square-fill"></span></a>
                                        {/if}
                                    </div>

                                    <div class="d-inline-block">
                                        <div id="primaryResourceContainer">
                                            <input type="hidden" id="scheduleId" {formname key=SCHEDULE_ID} value="{$ScheduleId}" />
                                            <input class="resourceId" type="hidden" id="primaryResourceId" {formname key=RESOURCE_ID}
                                                value="{$ResourceId}" />
                                            {displayResource resource=$Resource}
                                        </div>

                                        <div id="additionalResources">
                                            {foreach from=$AvailableResources item=resource}
                                            {if is_array($AdditionalResourceIds) && in_array($resource->Id, $AdditionalResourceIds)}
                                            <input class="resourceId" type="hidden" name="{FormKeys::ADDITIONAL_RESOURCES}[]"
                                                value="{$resource->Id}" />
                                            {displayResource resource=$resource}
                                            {/if}
                                            {/foreach}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 mb-3">
                        <div class="card-header bg-body-tertiary border-0 py-3">
                            <div class="fw-bold">詳細</div>
                            <div class="small text-muted">連絡・通知事項</div>
                        </div>
                        <div class="card-body p-3 p-lg-4">
                            <div class="reservationDescription">
                                <div class="form-group">
                                    <label class="fw-bold mb-1" for="description">
                                        {translate key="ReservationDescription"}{if $DescriptionRequired}<i
                                            class="bi bi-asterisk text-danger align-top text-small"></i>
                                        {/if}
                                    </label>
                                    <textarea id="description" name="{FormKeys::DESCRIPTION}" class="form-control has-feedback"
                                        {if $DescriptionRequired}required="required" {/if}>{$Description}</textarea>
                                    <div class="form-text">入力内容は予約一覧に表示されます。</div>
                                </div>

                                {if !empty($ReferenceNumber)}
                                <div class="form-group mt-3">
                                    <label class="fw-bold d-block">{translate key=ReferenceNumber}</label>
                                    <span>{$ReferenceNumber}</span>
                                </div>
                                {/if}
                            </div>

                            <div class="mt-4">
                                <div id="custom-attributes-placeholder"></div>
                            </div>

                            {if $UploadsEnabled}
                            <div class="mt-4">
                                <div class="reservationAttachments">
                                    <label class="fw-bold mb-1 d-block">{translate key=AttachFile} <span
                                            class="note fst-italic">({$MaxUploadSize} MB {translate key=Maximum})</span>
                                    </label>

                                    <div id="reservationAttachments">
                                        <div class="attachment-item d-flex flex-wrap align-items-center gap-2">
                                            <label class="fw-bold mb-0" for="reservationUploadFile">添付ファイル</label>
                                            <input type="file" {formname key=RESERVATION_FILE multi=true} id="reservationUploadFile"
                                                class="form-control form-control-sm w-auto" />
                                            <a class="add-attachment link-primary" href="#">{translate key=Add}<i
                                                    class="bi bi-plus-square-fill ms-1"></i></a>
                                            <a class="remove-attachment link-primary" href="#"><span
                                                    class="visually-hidden">{translate key=Delete}</span><i
                                                    class="bi bi-dash-square-fill"></i></a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {/if}

                            {if $Terms != null}
                            <div class="mt-4" id="termsAndConditions">
                                {if $TermsAccepted}
                                <div class="rounded border bg-body-tertiary px-3 py-2">
                                    <i class="bi bi-check-square-fill me-1"></i>{translate key=IAccept}
                                    <a href="{$Terms->DisplayUrl()}" class="link-primary"
                                        target="_blank">{translate key=TheTermsOfService}</a>
                                </div>
                                {else}
                                <div class="form-check rounded border bg-body-tertiary px-3 py-2">
                                    <input class="form-check-input" type="checkbox" id="termsAndConditionsAcknowledgement"
                                        {formname key=TOS_ACKNOWLEDGEMENT} {if $TermsAccepted}checked="checked" {/if} />
                                    <label for="termsAndConditionsAcknowledgement">{translate key=IAccept}</label>
                                    <a href="{$Terms->DisplayUrl()}" class="link-primary"
                                        target="_blank">{translate key=TheTermsOfService}</a>
                                </div>
                                {/if}
                            </div>
                            {/if}
                        </div>
                    </div>

                    <div class="card shadow-sm border-0">
                        <div class="card-body p-3 p-lg-4">
                            <div class="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
                                <div>
                                    <div class="fw-bold">確認して保存</div>
                                    <div class="small text-muted">内容を見直したら、ここからそのまま保存できます。</div>
                                </div>
                                <div class="d-flex flex-wrap gap-2 justify-content-lg-end">
                                    <button type="button" class="btn btn-sm btn-outline-secondary"
                                        onclick="window.location='{$ReturnUrl}'">
                                        <i class="bi bi-arrow-left-circle-fill"></i>
                                        <span class="d-none d-sm-inline-block">{translate key='Cancel'}</span>
                                    </button>
                                    {block name="submitButtons"}
                                    <button type="button" class="btn btn-sm btn-primary save create btnCreate">
                                        <i class="bi bi-check-circle"></i>
                                        {translate key='Create'}
                                    </button>
                                    {/block}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 reservation-sidebar">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-body-tertiary border-0 py-3">
                            <div class="fw-bold">予約内容確認</div>
                        </div>
                        <div class="card-body p-3">
                            <div class="small text-muted mb-1">現在の予約者</div>
                            <div class="fw-bold mb-3" id="reservationOwnerSummary">
                                {if $ShowUserDetails && $ShowReservationDetails}
                                {$ReservationUserName}
                                {else}
                                {translate key=Private}
                                {/if}
                            </div>

                            <div class="small text-muted mb-1">用途</div>
                            <div class="fw-bold mb-3" id="reservationPurposeSummary">未入力</div>

                            <div class="small text-muted mb-1">会議室</div>
                            <div class="fw-bold mb-3" id="reservationResourceSummary">{if isset($Resource) && $Resource}{$Resource->Name}{else}-{/if}</div>

                            <div class="small text-muted mb-1">日時</div>
                            <div class="mb-3">
                                {if isset($StartDate) && isset($EndDate)}
                                {formatdate date=$StartDate} - {formatdate date=$EndDate}
                                {else}
                                未設定
                                {/if}
                            </div>

                            {if !empty($ReferenceNumber)}
                            <div class="small text-muted mb-1">{translate key=ReferenceNumber}</div>
                            <div class="mb-3">{$ReferenceNumber}</div>
                            {/if}

                            <div class="small text-muted mb-1">連絡事項</div>
                            <div class="mb-3" id="reservationDescriptionSummary" style="white-space: pre-line;">{if !empty($Description)}{$Description|escape}{else}未入力{/if}</div>

                            <div class="rounded border bg-body-tertiary px-3 py-2 small text-muted">
                                予約のルール<br />
                                ・部屋使用用途と予約者氏名・内線は必ず入力してください。情報は予約交渉などに利用されます。<br />
                                ・会議室は教育・研究など学内イベントが優先です。個人利用は極力控えてください。<br />
                                ・連絡・通知事項に書いた内容は予約一覧にも表示されます。必要な連絡だけ簡潔に残してください。
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <input type="hidden" id="reservationTitle" {formname key=RESERVATION_TITLE} value="{$ReservationTitle|default:''}" />

            <input type="hidden" {formname key=RESERVATION_ID} value="{$ReservationId}" />
            <input type="hidden" {formname key=REFERENCE_NUMBER} value="{$ReferenceNumber}" id="referenceNumber" />
            <input type="hidden" {formname key=RESERVATION_ACTION} value="{$ReservationAction}" />
            <input type="hidden" {formname key=DELETE_REASON} value="" id="hdnDeleteReason" />

            <input type="hidden" {formname key=SERIES_UPDATE_SCOPE} id="hdnSeriesUpdateScope"
                value="{SeriesUpdateScope::FullSeries}" />

            {csrf_token}

            {if $UploadsEnabled}
            {block name='attachments'}
            {/block}
            {/if}

            <div id="retrySubmitParams" class="d-none"></div>
        </form>
    </div>
</div>

<div class="modal fade" id="dialogResourceGroups" tabindex="-1" role="dialog" aria-labelledby="resourcesModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="resourcesModalLabel">{translate key=AddResources}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
            </div>
            <div class="modal-body">
                <div id="resourceGroups"></div>
            </div>
            <div class="modal-footer">
                <div id="checking-availability" class="float-start">{translate key=CheckingAvailability} <div
                        class="spinner-border spinner-border-sm" role="status"></div>
                </div>
                <div id="checking-availability-error" class="float-start no-show">
                    {translate key=CheckingAvailabilityError}</div>
                <button type="button" class="btn btn-outline-secondary btnClearAddResources"
                    data-bs-dismiss="modal">{translate key='Cancel'}</button>
                <button type="button" class="btn btn-primary btnConfirmAddResources">{translate key='Done'}</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="dialogAddAccessories" tabindex="-1" role="dialog" aria-labelledby="accessoryModalLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="accessoryModalLabel">{translate key=AddAccessories}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
            </div>
            <div class="modal-body">
                <table class="table table-sm">
                    <thead>
                        <tr>
                            <th>{translate key=Accessory}</th>
                            <th>{translate key=QuantityRequested}</th>
                            <th>{translate key=QuantityAvailable}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$AvailableAccessories item=accessory}
                        <tr accessory-id="{$accessory->GetId()}">
                            <td>{$accessory->GetName()}</td>
                            <td>
                                <input type="hidden" class="name" value="{$accessory->GetName()}" />
                                <input type="hidden" class="id" value="{$accessory->GetId()}" />
                                <input type="hidden" class="resource-ids"
                                    value="{$accessory->ResourceIds()|join:','}" />
                                <label for="accessory{$accessory->GetId()}"
                                    class="visually-hidden">{$accessory->GetName()}</label>
                                {if $accessory->GetQuantityAvailable() == 1}
                                <input class="form-check-input" type="checkbox" name="accessory{$accessory->GetId()}"
                                    id="accessory{$accessory->GetId()}" value="1" size="3" aria-label="checkbox" />
                                {else}
                                <input type="number" min="0" max="999"
                                    class="form-control form-control-sm accessory-quantity"
                                    name="accessory{$accessory->GetId()}" id="accessory{$accessory->GetId()}" value="0"
                                    size="3" />
                                {/if}
                            </td>
                            <td accessory-quantity-id="{$accessory->GetId()}"
                                accessory-quantity-available="{$accessory->GetQuantityAvailable()}">
                                {$accessory->GetQuantityAvailable()|default:'&infin;'}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>

            </div>
            <div class="modal-footer">
                {cancel_button}
                <button id="btnConfirmAddAccessories" type="button"
                    class="btn btn-primary">{translate key='Done'}</button>
            </div>
        </div>
    </div>
</div>


<div id="wait-box" class="modal fade" aria-labelledby="update-boxLabel" data-bs-backdrop="static" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-body">
                <div id="creatingNotification" class="text-center">
                    <h3 id="createUpdateMessage" class="d-none">
                        {block name="ajaxMessage"}
                        {translate key=CreatingReservation}
                        {/block}
                    </h3>
                    <h3 id="checkingInMessage" class="d-none">
                        {translate key=CheckingIn}
                    </h3>
                    <h3 id="checkingOutMessage" class="d-none">
                        {translate key=CheckingOut}
                    </h3>
                    <h3 id="joiningWaitingList" class="d-none">
                        {translate key=AddingToWaitlist}
                    </h3>
                    <div class="spinner-border text-secondary" style="width: 3rem; height: 3rem;" role="status"></div>
                </div>
                <div id="result" class="text-center"></div>
            </div>
        </div>
    </div>
</div>

<div id="user-availability-box"></div>

</div>

{block name=extras}{/block}

{include file="javascript-includes.tpl"}

{control type="DatePickerSetupControl" ControlId="BeginDate" DefaultDate=$StartDate MinDate=$AvailabilityStart MaxDate=$AvailabilityEnd FirstDay=$FirstWeekday}
{control type="DatePickerSetupControl" ControlId="EndDate" DefaultDate=$EndDate MinDate=$AvailabilityStart MaxDate=$AvailabilityEnd FirstDay=$FirstWeekday}
{control type="DatePickerSetupControl" ControlId="EndRepeat" DefaultDate=$RepeatTerminationDate MinDate=$StartDate MaxDate=$AvailabilityEnd FirstDay=$FirstWeekday}
{control type="DatePickerSetupControl" ControlId="RepeatDate" MaxDate=$AvailabilityEnd FirstDay=$FirstWeekday MinDate=Date::Now()->ToTimezone($Timezone) Multiple=false}

{vendor_js src="moment/2.13.0/js/moment.min.js"}
{jsfile src="resourcePopup.js"}
{jsfile src="userPopup.js"}
{jsfile src="date-helper.js"}
{jsfile src="recurrence.js"}
{jsfile src="reservation.js"}
{jsfile src="autocomplete.js"}
{jsfile src="force-numeric.js"}
{jsfile src="reservation-reminder.js"}
{jsfile src="ajax-helpers.js"}
{vendor_js src="jqtree/1.6.2/js/tree.jquery.js"}

{include file="Reservation/pdf_libraries.tpl"}
<script type="text/javascript">
    $(function() {
        var scopeOptions = {
            instance: '{SeriesUpdateScope::ThisInstance}',
            full: '{SeriesUpdateScope::FullSeries}',
            future: '{SeriesUpdateScope::FutureInstances}'
        };

        var reservationOpts = {
            additionalResourceElementId: '{FormKeys::ADDITIONAL_RESOURCES}',
            accessoryListInputId: '{FormKeys::ACCESSORY_LIST}[]',
            returnUrl: '{$ReturnUrl}',
            scopeOpts: scopeOptions,
            createUrl: 'ajax/reservation_save.php',
            updateUrl: 'ajax/reservation_update.php',
            deleteUrl: 'ajax/reservation_delete.php',
            checkinUrl: 'ajax/reservation_checkin.php?action={ReservationAction::Checkin}',
            checkoutUrl: 'ajax/reservation_checkin.php?action={ReservationAction::Checkout}',
            waitlistUrl: 'ajax/reservation_waitlist.php',
            userAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::User}",
            groupAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::Group}",
            changeUserAutocompleteUrl: "ajax/autocomplete.php?type={AutoCompleteType::MyUsers}",
            maxConcurrentUploads: '{$MaxUploadCount}',
            guestLabel: '({translate key=Guest})',
            accessoriesUrl: 'ajax/available_accessories.php?{QueryStringKeys::START_DATE}=[sd]&{QueryStringKeys::END_DATE}=[ed]&{QueryStringKeys::START_TIME}=[st]&{QueryStringKeys::END_TIME}=[et]&{QueryStringKeys::REFERENCE_NUMBER}=[rn]',
            resourcesUrl: 'ajax/unavailable_resources.php?{QueryStringKeys::SCHEDULE_ID}={$ScheduleId}&{QueryStringKeys::START_DATE}=[sd]&{QueryStringKeys::END_DATE}=[ed]&{QueryStringKeys::START_TIME}=[st]&{QueryStringKeys::END_TIME}=[et]&{QueryStringKeys::REFERENCE_NUMBER}=[rn]',
            creditsUrl: 'ajax/reservation_credits.php',
            creditsEnabled: '{$CreditsEnabled}',
            emailUrl: 'ajax/reservation_email.php?{QueryStringKeys::REFERENCE_NUMBER}={$ReferenceNumber}',
            availabilityUrl: 'ajax/availability.php?{QueryStringKeys::SCHEDULE_ID}={$ScheduleId}',
            maximumResources: {$MaximumResources|default:0}
        };

        var reminderOpts = {
            reminderTimeStart: '{$ReminderTimeStart}',
            reminderTimeEnd: '{$ReminderTimeEnd}',
            reminderIntervalStart: '{$ReminderIntervalStart}',
            reminderIntervalEnd: '{$ReminderIntervalEnd}'
        };

        var reservation = new Reservation(reservationOpts);
        reservation.init('{$UserId}', '{format_date date=$StartDate key=system_datetime timezone=$Timezone}', '{format_date date=$EndDate key=system_datetime timezone=$Timezone}');

        var reminders = new Reminder(reminderOpts);
        reminders.init();

        reservation.addResourceGroups({$ResourceGroupsAsJson});

        var recurOpts = {
            repeatType: '{$RepeatType}',
            repeatInterval: '{$RepeatInterval}',
            repeatMonthlyType: '{$RepeatMonthlyType}',
            repeatWeekdays: [{foreach from=$RepeatWeekdays item=day}{$day}, {/foreach}],
            autoSetTerminationDate: $('#referenceNumber').val() != '',
            customRepeatExclusions: ['{formatdate date=$StartDate key=system}']
        };

        var recurrence = new Recurrence(recurOpts);
        recurrence.init();

        recurrence.onChange(reservation.repeatOptionsChanged);

        {foreach from=$CustomRepeatDates item=date}
        recurrence.addCustomDate('{format_date date=$date key=system timezone=$Timezone}',
        '{format_date date=$date key=schedule_daily timezone=$Timezone}');
        {/foreach}

        var ajaxOptions = {
            target: '#result', // target element(s) to be updated with server response
            beforeSubmit: reservation.preSubmit, // pre-submit callback
            success: reservation.showResponse // post-submit callback
        };

        $('#form-reservation').submit(function() {
            $(this).ajaxSubmit(ajaxOptions);
            return false;
        });

        $('#userName').bindUserDetails();

        // jsPDF
        {include file="Reservation/pdf.tpl"}
        //

        translateTooltips();

    });
    $('.modal').on('shown.bs.modal', function() {
        $(this).find('[autofocus]').focus();
    });
</script>

<script>
    function translateTooltips() {
        var resourcesContainer = document.querySelector('#reservation-resources');
        var resources = [].slice.call(resourcesContainer.querySelectorAll('[data-bs-toggle="tooltip"]'));
        resources.forEach(function(resource) {
            var tooltipType = resource.getAttribute('data-bs-title');
            if (tooltipType === 'approval') {
                var tooltipText = "{translate key=RequiresApproval}";
            }
            if (tooltipType === 'checkin') {
                var tooltipText ="{translate key=RequiresCheckInNotification}";
            }
            if (tooltipType === 'autorelease') {
                var text = "{translate key=AutoReleaseNotification args='%s'}";
                    var tooltipText = text.replace('%s', resource.getAttribute('data-autorelease'));
                }
                resource.setAttribute('data-bs-title', tooltipText);
                new bootstrap.Tooltip(resource);
            });
        }
    </script>

    {include file='globalfooter.tpl'}
