<div>
	<div id="updateUserResults" class="alert alert-danger no-show validationSummary">
		<ul>
			{async_validator id="emailformat" key="ValidEmailRequired"}
			{async_validator id="uniqueemail" key="UniqueEmailRequired"}
			{async_validator id="uniqueusername" key="UniqueUsernameRequired"}
			{async_validator id="updateAttributeValidator" key=""}
		</ul>
	</div>
	<div class="row gy-2">
		<div class="col-sm-12 col-md-6">

			<div class="form-group">
				<label class="fw-bold" for="username">{translate key="Username"}<i
						class="bi bi-asterisk text-danger align-top" style="font-size: 0.5rem;"></i></label>
				<input type="text" {formname key="USERNAME"} class="required form-control has-feedback" required
					id="username" value="{$User->Username()}" />
				<small class="text-muted">`xxx-lab` 形式を推奨します（例: `chemistry-lab`）。</small>
			</div>
		</div>

		<div class="col-sm-12 col-md-6">
			<div class="form-group">
				<label class="fw-bold" for="email">{translate key="Email"}<i
						class="bi bi-asterisk text-danger align-top" style="font-size: 0.5rem;"></i></label>
				<input type="text" {formname key="EMAIL"} class="required form-control has-feedback" required id="email"
					value="{$User->EmailAddress()}" />
				<small class="text-muted">研究室代表者のメールアドレスを設定してください。</small>
			</div>
		</div>
		<input type="hidden" {formname key="FIRST_NAME"} value="{$User->Username()}" />
		<input type="hidden" {formname key="LAST_NAME"} value="" />

		<div class="col-sm-12 col-md-6">
			<div class="form-group">
				<label class="fw-bold" for="timezone">{translate key="Timezone"}</label>
				<select {formname key='TIMEZONE'} id='timezone' class="form-select">
					{html_options values=$Timezones output=$Timezones selected="{$User->Timezone()}"}
				</select>
			</div>
		</div>

		<div class="col-sm-12 col-md-6">
			<div class="form-group">
				<label class="fw-bold" for="phone">{translate key="Phone"}</label>
				<input type="text" {formname key="PHONE"} class="form-control" id="phone"
					value="{$User->GetAttribute(UserAttribute::Phone)}" />
			</div>
		</div>
		<input type="hidden" {formname key="ORGANIZATION"} value="" />
		<input type="hidden" {formname key="POSITION"} value="" />

		{foreach from=$Attributes item=attribute}
			<div class="col-sm-12 col-md-6">
				{control type="AttributeControl" attribute=$attribute value={$User->GetAttributeValue($attribute->Id())} }
			</div>
		{/foreach}
	</div>
</div>
