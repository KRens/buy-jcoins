<?php
namespace wcf\form;

use wcf\util\ArrayUtil;
use wcf\system\exception\UserInputException;
use wcf\system\WCF;
use wcf\util\StringUtil;
use wcf\data\user\UserProfile;
use wcf\data\user\jcoins\statement\UserJcoinsStatementAction;
use wcf\system\user\notification\UserNotificationHandler;
use wcf\system\user\notification\object\JCoinsTransferNotificationObject;

/**
 * A buying form for jcoins
 *
 * @author Koen Rens
 * @package be.ictscripters.jcoinsBuy
 * @subpackage wcf.form
 */
class JCoinsBuyForm extends AbstractForm {

	private $validationurl = "http://dimopay.com/payment/validate.php";
	private $siteid = JCOINS_BUY_SITEID;
	private $sitepass = JCOINS_BUY_SITEPASS;

	/**
	 * the sum to transfer
	 * @var string
	 */
	public $pay = '';

	/**
	 * the sum to transfer in case of other amount selected
	 * @var string
	 */
	public $otheramount = '';

	/**
	 * @see wcf\page\AbstractPage::$enableTracking
	 */
	public $enableTracking = true;

	/**
	 * @see wcf\page\AbstractPage::$loginRequired
	 */
	public $loginRequired = true;

	/**
	 * @see wcf\page\AbstractPage::$neededModules
	 */
	public $neededModules = array('MODULE_JCOINS');

	/**
	 * @see wcf\page\AbstractPage::$neededPermissions
	 */
	public $neededPermissions = array('user.jcoins.canUse', 'user.jcoins.canBuy');

	/**
	 * the sum to transfer
	 * @var integer
	 */
	public $sum = 0;

	/**
	 * all user name for the transfer
	 * @var string
	 */
	public $usernames = "";
	
	/**
	* true if transfer is succeded
	* @var boolean
	*/
	public $success = false;	

	/**
	 * @see wcf\page\IPage::readParameters()
	 */
	public function readParameters() {
		parent::readParameters();

		if (isset($_REQUEST['id']) && !isset($_POST['username'])) {
			$this->userID = intval($_REQUEST['id']);
			$this->user[] = UserProfile::getUserProfile($this->userID);
		}
	}

	/**
	 * @see wcf\form\IForm::readFormParameters()
	 */
	public function readFormParameters() {
		parent::readFormParameters();
		if (isset($_POST['pay'])) $this->pay = StringUtil::trim($_POST['pay']);
		if (isset($_POST['otheramount'])) $this->otheramount = StringUtil::trim($_POST['otheramount']);
		if (isset($_POST['sum'])) $this->sum = StringUtil::trim($_POST['sum']);
		if (isset($_POST['username'])) $this->usernames = StringUtil::trim($_POST['username']);

		if (count(explode(',', $this->usernames)) > 0) {
			$users = explode(',', $this->usernames);

			$this->user = UserProfile::getUserProfilesByUsername(ArrayUtil::trim(explode(',', $this->usernames)));
		}
	}

	/**
	 * @see wcf\form\IForm::validate()
	 */
	public function validate() {

		if(!isset($_POST['selectpayment'])){

			if (StringUtil::length($this->sum) > 55) {
				throw new UserInputException('sum', 'tooLong');
			}

			if (StringUtil::length($this->sum) < 5) {
				throw new UserInputException('sum', 'tooShort');
			}

			if (count($this->user) == 0) {
				throw new UserInputException('username', 'empty');
			}

			foreach ($this->user as $user) {
				if ($user->isIgnoredUser(WCF::getUser()->userID)) {
					WCF::getTPL()->assign(array(
							'ignoredUsername' => $user->username
						));

					throw new UserInputException('user', 'isIgnored');
				}
			}

			parent::validate();
		}
	}

	/**
	 * @see wcf\form\IForm::save()
	 */
	public function save() {

		if(!isset($_POST['selectpayment'])){

			parent::save();



			$this->sum=htmlspecialchars(addslashes($this->sum));


			//sitecode meesturen
			$url  = $this->validationurl."?".
				"type=payme&tologin=".urlencode(WCF::getUser()->username)."&siteid=".urlencode($this->siteid)."&sitepass=".urlencode($this->sitepass)."&pincode=".urlencode($this->sum);

			$result = trim(@file_get_contents($url)); //witregels ook weghalen in antwoord

			$resultvalue=explode("|",$result);

			if($result=='-1'){
				/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">Ongeldige pincode - the pincode is invalid</span></p>";*/
				throw new UserInputException('sum', 'invalidPaycode');
			}
			elseif($result=='-2'){ //You provide incorrect data towards our validationurl. We can not authorize you.
				/* echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">No access</span></p>";*/
				throw new UserInputException('sum', 'noAccessPaymentProvider');
			}
			elseif($result=='-3'){
				/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">No pincode entered</span></p>";*/
				throw new UserInputException('sum', 'noPaycodeEntered');
			}
			elseif($result=='-4'){
				/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">Pincode is niet meer geldig, hij werd al gebruikt.<br>Pincode not valid anymore, it has been claimed by you some time ago</span></p>";*/
				throw new UserInputException('sum', 'paycodeUsed');
			}
			elseif($result=='-5'){
				/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">Pincode is niet meer geldig, hij werd al gebruikt, maar kon niet worden geint.<br>Pincode not valid anymore, it has been claimed by you some time ago. Unfortunately it could not be collected.</span></p>";*/
				throw new UserInputException('sum', 'paycodeUsedFailed');
			}
			elseif($result=='-10'){
				/*  echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">Ongeldig bedrag betaald. Invalid amount payed. The provided pincode has a value of less then 1 eurocent and can not be validated.</span></p>";*/
				throw new UserInputException('sum', 'invalidAmount');
			}
			elseif($result=='-20'){
				/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">Your payment still needs to be validated manually. This might take a few days.</span></p>";*/
				throw new UserInputException('sum', 'paycodeNotProcessed');
			}
			elseif($resultvalue[0]=='1'){
			/*
				echo "<p class=\"success\" id=\"success\"><span class=\"info_inner\">Geldige pincode, betaling succesvol.<br>Valid pincode, payment succesful</span></p>";*/

				if(!is_numeric($resultvalue[1]) || $resultvalue[1] < '1'){
					/*echo "<p class=\"info\" id=\"error\"><span class=\"info_inner\">This payment code has an invalid value. Contact your webmaster and provide them the entered code.</span></p>";*/
					throw new UserInputException('sum', 'invalidValue');
				}
				//Reward your users here!
				//$resultvalue[1] contains the value in eurocent that the user paid you, this is how much you as a webmaster earn



				//Extra controle inbouwen: je kan aan max 1 user uitbetalen !!!
				//
				// !!!!
				foreach ($this->user as $user) {
					$this->statementAction = new UserJcoinsStatementAction(array(), 'create', array(
							'data' => array(
								'reason' => WCF::getLanguage()->get('wcf.jcoins.buy'),
								'sum' => $resultvalue[1],
								'userID' => $user->userID,
								'executedUserID' => WCF::getUser()->userID,
								'isModTransfer' => '0'
							),
							'changeBalance' => 1
						));
					$this->statementAction->validateAction();
					$return = $this->statementAction->executeAction();

					UserNotificationHandler::getInstance()->fireEvent('jCoinsTransfer', 'de.joshsboard.wcf.jcoins.transfer.notification', new JCoinsTransferNotificationObject($return['returnValues']), array($user->userID));

					/*
			if (!$this->isModerativ) {
				$this->statementAction = new UserJcoinsStatementAction(array(), 'create', array(
				    'data' => array(
					'reason' => $this->reason,
					'sum' => $resultvalue[1] * -1,
					'executedUserID' => $user->userID
				    ),
				    'changeBalance' => 1
				));
				$this->statementAction->validateAction();
				$this->statementAction->executeAction();
			} */
				}
			}
			$this->saved();

			$this->sum = 0;
			$this->reason = "";
			$this->user = array();
			$this->success = true;
			$this->isModerativ = 0;
		}
	}





	/**
	 * @see wcf\page\IPage::assignVariables()
	 */
	public function assignVariables() {
		parent::assignVariables();

		if(isset($_GET['country']) && is_numeric($_GET['country'])){
			$country=htmlspecialchars(addslashes(StringUtil::trim($_GET['country'])));
		}else{
			$country = '';
			$ip = $_SERVER['REMOTE_ADDR'];

			$host = gethostbyaddr( $ip ); // Get host by ip
			if( $host == $ip )
			{
				// The host is the same as the ip, thus: unknown
				//return "Onbekend";
			}

			$hostsplit = explode( ".", $host ); // Split the host based on the dots
			$country = array_pop( $hostsplit ); // PGet the last item

			if($country=="be"){
				$country=32;
			}elseif($country=="nl"){
				$country=31;
			}elseif($country=="fr"){
				$country=33;
			}elseif($country=="it"){
				$country=39;
			}elseif($country=="ch"){
				$country=41;
			}elseif($country=="at"){
				$country=43;
			}elseif($country=="gb"){
				$country=44;
			}elseif($country=="de"){
				$country=49;
			}elseif($country=="lu"){
				$country=352;
			}else{
				$country=1;
			}
		}

		$paymethod='';
		$amount='';

		if($this->pay!=''){
			$paymentmethod=explode("-",htmlspecialchars(addslashes($this->pay)));
			$method=$paymentmethod[0];

			unset($amount);
			//User chooses own amount to buy
			if($this->pay==100 && $this->otheramount!='' && $this->otheramount>4){
				$amount="&amount=".$this->otheramount;
			}else{
				//User picked predefined amount
				$amount="&consumerprice=";
				if(isset($paymentmethod[1])){
					$amount.=$paymentmethod[1];
				}
			}

			//unset($paymethod);
			if($method==1){
				$paymethod="&betaalmethode=call";
			}elseif($method==2){
				$paymethod="&betaalmethode=sms";
			}elseif($method==3){
				$paymethod="&betaalmethode=bank";
			}elseif($method==4){
				$paymethod="&betaalmethode=paysafecard";
			}elseif($method==5){
				$paymethod="&betaalmethode=ideal";
			}elseif($method==6){
				$paymethod="&betaalmethode=paypal";
			}elseif($method==8){
				$paymethod="&betaalmethode=bancontact";
			}
		}

		WCF::getTPL()->assign(array(
				'country' => $country,
				'pay' => $this->pay,
				'amount' => $amount,
				'paymethod' => $paymethod,
				'success' => $this->success,
				'sum' => $this->sum
			));
	}

}
