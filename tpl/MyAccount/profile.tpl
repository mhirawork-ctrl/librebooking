{include file='globalheader.tpl' Validator=true}

<div class="page-profile">

    <div id="profile-box" class="default-box card shadow col-12 col-sm-8 mx-auto">

        <form method="post" ajaxAction="{ProfileActions::Update}" id="form-profile" class="was-validated"
            action="{$smarty.server.SCRIPT_NAME}" role="form" data-bv-submitbuttons='button[type="submit"]'
            data-bv-onerror="enableButton" data-bv-onsuccess="enableButton" data-bv-live="enabled">

            <div class="card-body">
                <h1 class="text-center border-bottom mb-2">{translate key=EditProfile}</h1>

                <div class="d-none alert alert-success" role="alert" id="profileUpdatedMessage">
                    <i class="bi bi-check-circle-fill text-success"></i> {translate key=YourProfileWasUpdated}
                </div>

                <div class="validationSummary alert alert-danger d-none" id="validationErrors">
                    <ul>
                        {async_validator id="username" key="UserNameRequired"}
                        {async_validator id="emailformat" key="ValidEmailRequired"}
                        {async_validator id="uniqueemail" key="UniqueEmailRequired"}
                        {async_validator id="uniqueusername" key="UniqueUsernameRequired"}
                        {async_validator id="phoneRequired" key="PhoneRequired"}
                        {async_validator id="additionalattributes" key=""}
                    </ul>
                </div>

                <div class="row gy-2">
                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="username">{translate key="Username"}</label>
                            {if $AllowUsernameChange}
                                {textbox name="USERNAME" value="Username" required="required" data-bv-notempty="true" autofocus="autofocus" data-bv-notempty-message="{translate key=UserNameRequired}"}
                            {else}
                                <span>{$Username}</span>
                                <input type="hidden" {formname key=USERNAME} value="{$Username}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="email">{translate key="Email"}</label>
                            {if $AllowEmailAddressChange}
                                {textbox type="email" name="EMAIL" class="input" value="Email" required="required" data-bv-notempty="true" data-bv-notempty-message="{translate key=ValidEmailRequired}"
                                data-bv-emailaddress="true"
                                data-bv-emailaddress-message="{translate key=ValidEmailRequired}" }
                            {else}
                                <span>{$Email}</span>
                                <input type="hidden" {formname key=EMAIL} value="{$Email}" />
                            {/if}
                        </div>
                    </div>

                    <input type="hidden" {formname key=FIRST_NAME} value="{$FirstName}" />
                    <input type="hidden" {formname key=LAST_NAME} value="{$LastName}" />

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="homepage">{translate key="DefaultPage"}</label>
                            <select {formname key='DEFAULT_HOMEPAGE'} id="homepage" class="form-select">
                                {html_options values=$HomepageValues output=$HomepageOutput selected=$Homepage}
                            </select>
                        </div>

                    </div>
                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="timezoneDropDown">{translate key="Timezone"}</label>
                            <select {formname key='TIMEZONE'} class="form-select" id="timezoneDropDown">
                                {html_options values=$TimezoneValues output=$TimezoneOutput selected=$Timezone}
                            </select>
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="phone">電話番号（内線）</label>
                            {if $AllowPhoneChange}
                                <textarea id="phone" {formname key="PHONE"} class="form-control" rows="4"
                                    {if $RequirePhone}required="required" data-bv-notempty="true"
                                    data-bv-notempty-message="{translate key=PhoneRequired}" {/if}>{$Phone}</textarea>
                                <div class="form-text">複数ある場合は改行またはカンマ区切りで入力してください。予約フォームでは候補から選べます。</div>
                            {else}
                                <span>{$Phone|nl2br}</span>
                                <input type="hidden" {formname key=PHONE} value="{$Phone}" />
                            {/if}
                        </div>
                    </div>

                    <input type="hidden" {formname key=ORGANIZATION} value="{$Organization}" />
                    <input type="hidden" {formname key=POSITION} value="{$Position}" />

                    {foreach from=$Attributes item=attribute}
		                <div class="col-12 col-sm-6">
            		            {control type="AttributeControl" attribute=$attribute}
                        </div>
                    {/foreach}

                    <div class="d-grid mt-3">
                        <button type="submit" class="update btn btn-primary btn-block" name="{Actions::SAVE}"
                            id="btnUpdate">
                            {translate key='Update'}
                        </button>
                    </div>
                </div>
            </div>
            {csrf_token}
        </form>
    </div>
    {setfocus key='USERNAME'}

    {include file="javascript-includes.tpl" Validator=true}
    {jsfile src="ajax-helpers.js"}
    {jsfile src="autocomplete.js"}
    {jsfile src="profile.js"}

    <script type="text/javascript">
        function enableButton() {
            $('#form-profile').find('button').removeAttr('disabled');
        }

        $(document).ready(function() {
            var profilePage = new Profile();
            profilePage.init();

            var profileForm = $('#form-profile');

            profileForm
                .on('init.field.bv', function(e, data) {
                    var $parent = data.element.parents('.form-group');
                    var $icon = $parent.find('.form-control-feedback[data-bv-icon-for="' + data.field +
                        '"]');
                    var validators = data.bv.getOptions(data.field).validators;

                    if (validators.notEmpty) {
                        $icon.addClass('bi bi-asterisk').show();
                    }
                })
                .off('success.form.bv')
                .on('success.form.bv', function(e) {
                    e.preventDefault();
                });

            profileForm.bootstrapValidator();

        });
    </script>

    <div class="modal" id="waitModal" tabindex="-1" role="dialog" aria-labelledby="waitModalLabel"
        data-bs-backdrop="static" aria-hidden="true">
        {include file="wait-box.tpl" translateKey='Working'}
    </div>

</div>
{include file='globalfooter.tpl'}
