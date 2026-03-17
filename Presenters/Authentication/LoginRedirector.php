<?php

require_once(ROOT_DIR . 'Pages/Authentication/ILoginBasePage.php');

class LoginRedirector
{
    public static function Redirect(ILoginBasePage $page, $userSession = null)
    {
        $redirect = $page->GetResumeUrl();

        if (!empty($redirect)) {
            $page->Redirect(html_entity_decode($redirect));
        } else {
            $defaultId = $userSession?->HomepageId ?? ServiceLocator::GetServer()->GetUserSession()->HomepageId;
            $url = Pages::HomeUrlFromId($defaultId);
            $page->Redirect(empty($url) ? Pages::HomeUrlFromId(Pages::DEFAULT_HOMEPAGE_ID) : $url);
        }
    }
}
