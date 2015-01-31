{include file="documentHeader"}

{if JCOINS_BUY_CURRENCY=='USD'}
{capture assign=currency}${/capture}
{capture assign=currencyformat}.{/capture}
{else}
{capture assign=currency}€{/capture}
{capture assign=currencyformat},{/capture}
{/if}

<head>
	<title>{lang}wcf.jcoins.buy{/lang} - {PAGE_TITLE|language}</title>

	{include file='headInclude'}
</head>

<body id="tpl{$templateName|ucfirst}">

	{include file='header'}

	<header class="boxHeadline">
		<h1>{lang}wcf.jcoins.buy{/lang}</h1>
	</header>

	{include file='userNotice'}

	{if $errorField}
		<p class="error">{lang}wcf.global.form.error{/lang}</p>
	{/if}

	{if $success}
		<p class="success">{lang}wcf.jcoins.buy.success{/lang}</p>
	{/if}

	<form method="post" action="{link controller='JCoinsBuy'}{/link}">
		<div class="container containerPadding marginTop">
			<fieldset>
				<legend>{lang}wcf.jcoins.transfer.exchangeCode{/lang}</legend>

				<dl id="usernameDiv"{if $errorField == 'username'} class="formError"{/if}>
					<dt>
						<label for="usernameInput">{lang}wcf.user.username{/lang}</label>
					</dt>
					<dd>
						<input type="text" id="usernameInput" name="username" value="{$__wcf->getUser()->username}" class="medium" />
						{if $errorField == 'username'}
							<small class="innerError">
							{if $errorType == 'empty'}{lang}wcf.global.form.error.empty{/lang}{/if}
							{if $errorType == 'notFound'}{lang}wcf.user.error.username.notFound{/lang}{/if}
							{if $errorType == 'isIgnored'}{lang}wcf.jcoins.buy.userIgnores{/lang}{/if}
							</small>
						{/if}
					</dd>
				</dl>

				<script data-relocate="true">
					new WCF.Search.User('#usernameInput', null, false, null, true);
				</script>

				<dl id="sumDiv"{if $errorField == 'sum'} class="formError"{/if}>
					<dt>
						<label for="sumInput">{lang}wcf.jcoins.buy.code{/lang}</label>
					</dt>
					<dd>
						<input type="text" id="sumInput" name="sum" value="" class="medium" />
						{if $errorField == 'sum'}
							<small class="innerError">
							{if $errorType == 'tooLong'}{lang}wcf.jcoins.buy.error.tooLong{/lang}{/if}
							{if $errorType == 'tooShort'}{lang}wcf.jcoins.buy.error.tooShort{/lang}{/if}
							{if $errorType == 'invalidPaycode'}{lang}wcf.jcoins.buy.error.invalidPaycode{/lang}{/if}
							{if $errorType == 'noAccessPaymentProvider'}{lang}wcf.jcoins.buy.error.noAccessPaymentProvider{/lang}{/if}
							{if $errorType == 'noPaycodeEntered'}{lang}wcf.jcoins.buy.error.noPaycodeEntered{/lang}{/if}
							{if $errorType == 'paycodeUsed'}{lang}wcf.jcoins.buy.error.paycodeUsed{/lang}{/if}
							{if $errorType == 'paycodeUsedFailed'}{lang}wcf.jcoins.buy.error.paycodeUsedFailed{/lang}{/if}
							{if $errorType == 'invalidAmount'}{lang}wcf.jcoins.buy.error.invalidAmount{/lang}{/if}
							{if $errorType == 'paycodeNotProcessed'}{lang}wcf.jcoins.buy.error.paycodeNotProcessed{/lang}{/if}
							{if $errorType == 'invalidValue'}{lang}wcf.jcoins.buy.error.invalidValue{/lang}{/if}
							</small>
						{/if}
					</dd>
				</dl>			
				
			</fieldset>
		</div>

		<div class="formSubmit">
			<input type="hidden" id="reasonInput" name="reason" value="{lang}wcf.jcoins.buy{/lang}" />	
			<input type="submit" value="{lang}wcf.global.button.submit{/lang}" accesskey="s" />
			{@SECURITY_TOKEN_INPUT_TAG}
		</div>
	</form>
	
	
		<div class="container containerPadding marginTop">
			<fieldset>
				<legend>{lang}wcf.jcoins.buy.getCode{/lang}</legend>	
{if $pay && $country}
<a href='/JCoinsBuy/'>{lang}wcf.jcoins.buy.restart{/lang}</a><br><br>
<iframe src="https://dimopay.com/popup.php?p=payment/index&amp;logo=&amp;cur={JCOINS_BUY_CURRENCY}&amp;lang={JCOINS_BUY_LANGUAGE}&amp;country={if $country==1}0{else}{$country}{/if}{$amount}{$paymethod}" width="430" height="900" frameborder="0"></iframe>

{else}
	{capture assign=jcoinsBuyLink}{link controller='JCoinsBuy' encode=false}{/link}{/capture}
	<form method="post" id="paymentform"><table align="left" width="100%">
         <tr>
         <td colspan="4">{lang}wcf.jcoins.buy.selectCountry{/lang}: <select onchange="document.location.href='{$jcoinsBuyLink|encodeJS}{if $jcoinsBuyLink|strpos:'?' !== false}&{else}?{/if}country='+this.value;" style="margin-top: 4px; width: 174px; height: 25px;">

		    <option value="-1">{lang}wcf.jcoins.buy.selectCountry{/lang}</option>
            <option value="32"{if $country == '32'} selected{/if}>{lang}wcf.jcoins.buy.Belgium{/lang}</option>
            <option value="31"{if $country == '31'} selected{/if}>{lang}wcf.jcoins.buy.Netherlands{/lang}</option>
            <option value="33"{if $country == '33'} selected{/if}>{lang}wcf.jcoins.buy.France{/lang}</option>
            <option value="39"{if $country == '39'} selected{/if}>{lang}wcf.jcoins.buy.Italy{/lang}</option>
            <option value="41"{if $country == '41'} selected{/if}>{lang}wcf.jcoins.buy.Switzerland{/lang}</option>
            <option value="43"{if $country == '43'} selected{/if}>{lang}wcf.jcoins.buy.Austria{/lang}</option>
            <option value="44"{if $country == '44'} selected{/if}>{lang}wcf.jcoins.buy.GreatBritain{/lang}</option>
            <option value="49"{if $country == '49'} selected{/if}>{lang}wcf.jcoins.buy.Germany{/lang}</option>
            <option value="352"{if $country == '352'} selected{/if}>{lang}wcf.jcoins.buy.Luxemburg{/lang}</option>
		        <option value="1"{if $country == '1'} selected{/if}>{lang}wcf.jcoins.buy.countryOthers{/lang}</option>
          </select>
		  </td>
         </tr>
         <tr>
         <td colspan="4">&nbsp;</td>
         </tr>
         <tr>
          <td class="tab-title" width="4%">&nbsp;</td>
          <td class="tab-title" width="66%" style="font-weight:bold;">{lang}wcf.jcoins.buy.paymentMethod{/lang}</td>
          <td class="tab-title" width="15%" style="text-align:center;font-weight:bold;">{lang}wcf.jcoins.buy.Price{/lang}</td>
          <td class="tab-title" width="15%" style="text-align:center;font-weight:bold;">{lang}wcf.jcoins.buy.amountjCoins{/lang}</td>
         </tr>

{section name=i loop=31 start=1}
{capture assign=option}JCOINS_BUY_OPTION{$i}{/capture}
{capture assign=amount}JCOINS_BUY_OPTION{$i}_AMOUNT{/capture}
{capture assign=amountvariable}JCOINS_BUY_OPTION{$i}_AMOUNT{/capture}
{capture assign=amountdisplay}{$amountvariable|constant}{/capture}


{if $option|constant=='Call'}
{capture assign=icon}pay_phone.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.call{/lang}{/capture}
{capture assign=payid}1{/capture}

{if $amountdisplay>='130' && $amountdisplay<'150'}
{capture assign=payout}78{/capture}
{elseif $amountdisplay>='150' && $amountdisplay<'499'}
{capture assign=payout}86{/capture}
{elseif $amountdisplay>='499'}
{capture assign=payout}200{/capture}
{else}
{capture assign=payout}0{/capture}
{/if}

{elseif $option|constant=='SMS'}
{capture assign=icon}pay_sms.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.sms{/lang}{/capture}
{capture assign=payid}2{/capture}
{if $amountdisplay>='150' && $amountdisplay<'200'}
{capture assign=payout}55{/capture}
{elseif $amountdisplay>='200' && $amountdisplay<'499'}
{capture assign=payout}84{/capture}
{elseif $amountdisplay=='499' || $amountdisplay=='500'}
{capture assign=payout}200{/capture}
{elseif $amountdisplay>'500'}
{capture assign=payout}300{/capture}
{else}
{capture assign=payout}0{/capture}
{/if}

{elseif $option|constant=='Paysafecard'}
{capture assign=icon}pay_paysafecard.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.paysafecard{/lang}{/capture}
{capture assign=payid}4{/capture}
{capture assign=payout}{$amountdisplay*0.8|round:0}{/capture}
{elseif $option|constant=='Bancontact-mistercash'}
{capture assign=icon}pay_bancontact.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.bancontact{/lang}{/capture}
{capture assign=payid}8{/capture}
{capture assign=payout}{$amountdisplay*0.9801-25|round:0}{/capture}
{elseif $option|constant=='Wire-transfer'}
{capture assign=icon}pay_manual.gif{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.wireTransfer{/lang}{/capture}
{capture assign=payid}3{/capture}
{capture assign=payout}{$amountdisplay-35|round:0}{/capture}
{elseif $option|constant=='Paypal'}
{capture assign=icon}pay_paypal.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.PayPal{/lang}{/capture}
{capture assign=payid}6{/capture}
	{if $amountdisplay > '2500'}
	{capture assign=payout}{$amountdisplay*0.92|round:0}{/capture}
	{else}
	{capture assign=payout}{$amountdisplay-200|round:0}{/capture}
	{/if}
{elseif $option|constant=='iDeal'}
{capture assign=icon}pay_ideal.png{/capture}
{capture assign=label}{lang}wcf.jcoins.buy.iDeal{/lang}{/capture}
{capture assign=payid}5{/capture}
{capture assign=payout}{$amountdisplay-99|round:0}{/capture}
{else}
{capture assign=icon}0{/capture}
{capture assign=payid}0{/capture}
{capture assign=payout}0{/capture}
{/if}

{capture assign=payout}{$payout*JCOINS_BUY_MULTIPLIERBONUS+JCOINS_BUY_ADDEDBONUS|round:0}{/capture}

{if $option|constant!='Disabled'}
{if $option|constant=='iDeal' && $country != '31'}
{* No iDeal outside of Netherlands *}
{else}		
		<tr>
          <td class="tab-maintxt" style="text-align:center;"><input type="radio" value="{$payid}-{$amount|constant}" name="pay"></td>
          <td class="tab-maintxt"><img src="{$__wcf->getPath()}images/pay/{$icon}"> {$label}</td>
          <td class="tab-maintxt" style="text-align:center;">{$currency} {$amountdisplay/100|round:2|number_format:2:',':'.'}</td>
          <td class="tab-maintxt" style="text-align:center;">{$payout}</td>
         </tr>
{/if}
{/if}
{/section}

 
       
{if JCOINS_BUY_OPTIONCUSTOM}          		 
         <tr>
         <td colspan="4">&nbsp;</td>
         </tr> 
         <tr>
          <td class="tab-maintxt" style="text-align:center;"><input type="radio" value="100" name="pay" id="otheramountsubmit"></td>
          <td class="tab-maintxt">{lang}wcf.jcoins.buy.others{/lang}</td>
          <td class="tab-maintxt" style="text-align:center;">-</td>
          <td class="tab-maintxt" style="text-align:center;"><input type="text" name="otheramount" id="otheramount" value="0{$currencyformat}00" onclick="javascript:tickotheramount();"></input></td>
         </tr>   
{/if}         
         <tr>
         <td colspan="4">&nbsp;<input type="hidden" name="country" value="{$country}"></td>
         </tr>  
         <tr>
         <td colspan="4" style="text-align:center;"><input type="submit" name="selectpayment" value="{lang}wcf.jcoins.buy.goToPaymentScreen{/lang}"></td>
         </tr>          
       </table>
       {@SECURITY_TOKEN_INPUT_TAG}
       </form>
{/if}	
			</fieldset>
		</div>
	<script>
    function tickotheramount() {
		$("#otheramountsubmit").prop("checked", true);
	}
	</script>

	{include file='footer'}

</body>
</html>