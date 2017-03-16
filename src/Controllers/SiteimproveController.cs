﻿using EPiServer;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using EPiServer.Web.Routing;
using SiteImprove.EPiserver.Plugin.Repositories;
using System.Globalization;
using System.Net;
using System.Web.Mvc;

namespace SiteImprove.EPiserver.Plugin.Controllers
{
    [Authorize(Roles = "Administrators, WebAdmins, CmsAdmins")]
    public class SiteimproveController : Controller
    {
        ISettingsRepository settingsRepo;

        public SiteimproveController() : this(ServiceLocator.Current.GetInstance<ISettingsRepository>()) { }
        public SiteimproveController(ISettingsRepository settingsRepo)
        {
            this.settingsRepo = settingsRepo;
        }
        
        public JsonResult Token()
        {
            return Json(this.settingsRepo.getToken(), JsonRequestBehavior.AllowGet);
        }

        public ActionResult PageUrl(string contentId, string locale)
        {
            var contentRep = ServiceLocator.Current.GetInstance<IContentRepository>();
            var page = contentRep.Get<PageData>(
                new ContentReference(contentId),
                new LanguageSelector(locale));

            if (page != null && page.CheckPublishedStatus(PagePublishedStatus.Published))
            {
                return Json(SiteimproveHelper.GetExternalUrl(page), JsonRequestBehavior.AllowGet);
            }

            return new HttpStatusCodeResult((int)HttpStatusCode.BadRequest);
        }
    }
}
