"""
URL configuration for stress_monitoring project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from myapp import views

urlpatterns = [
    path('login_get/',views.login_get),
    path('login_post/',views.login_post),
    path('logout_get/',views.logout_get),
    path('forget_get/',views.forget_get),
    path('forgetpass_post/',views.forgetpass_post),

    # ========================================admin=================================================
    path('adminhome_get/',views.adminhome_get),
    path('addhr_get/',views.addhr_get),
    path('addhr_post/',views.addhr_post),
    path('viewhr_get/',views.viewhr_get),
    path('delete_hr/<id>',views.delete_hr),
    path('edithr_get/<id>',views.edithr_get),
    path('edithr_post/',views.edithr_post),
    path('adminviewwork_get/',views.adminviewwork_get),
    path('adminchangepassword_get/',views.adminchangepassword_get),
    path('adminchangepassword_post/',views.adminchangepassword_post),
    path('adminviewteammember/<id>',views.adminviewteammember),
    path('adminviewteamleader/',views.adminviewteamleader),
    path('adminviewfeedback/',views.adminviewfeedback),
    path('admin_stress_report_get/',views.admin_stress_report_get,name='admin_stress_report_get'),
# ====================================================HR=============================================
    path('hrhome_get/',views.hrhome_get),
    path('hrviewprofile_get/',views.hrviewprofile_get),
    path('addteamleader_get/',views.addteamleader_get),
    path('addteamleader_post/',views.addteamleader_post),
    path('viewteamleader_get/',views.viewteamleader_get),
    path('editteamleader_get/<id>',views.editteamleader_get),
    path('editteamleader_post/',views.editteamleader_post),
    path('delete_teamleader/<id>',views.delete_teamleader),
    path('addteammember_get/',views.addteammember_get),
    path('addteammember_post/',views.addteammember_post),
    path('viewteammember_get/',views.viewteammember_get),
    path('editteammember_get/<id>', views.editteammember_get),
    path('editteammember_post/', views.editteammember_post),
    path('delete_teammember/<id>',views.delete_teammember),
    path('addwork_get/',views.addwork_get),
    path('addwork_post/',views.addwork_post),
    path('hrviewwork_get/',views.hrviewwork_get),
    path('editwork_get/<id>',views.editwork_get),
    path('editwork_post/',views.editwork_post),
    path('deletework_get/<id>',views.deletework_get),
    path('assignwork_get/',views.assignwork_get),
    path('assignwork_post/',views.assignwork_post),
    path('viewassignedwork_get/',views.viewassignedwork_get),
    path('deleteassignedwork_get/<id>',views.deleteassignedwork_get),
    path('hrviewfeedback/<id>',views.hrviewfeedback),
    path('viewteammemberswork/<id>',views.viewteammemberswork),
    path('hrchangepassword_get/',views.hrchangepassword_get),
    path('hrchangepassword_post/',views.hrchangepassword_post),
    path('hr_stress_report_get/',views.hr_stress_report_get,name='hr_stress_report_get'),

# =========================== team_leader==========================================
    path('teamleaderhome_get/',views.teamleaderhome_get),
    path('teamleaderviewprofile/',views.teamleaderviewprofile),
    path('viewteammember/',views.viewteammember),
    path('viewassignedwork/',views.viewassignedwork),
    path('viewworkassignedtomember_get/<id>',views.viewworkassignedtomember_get),
    path('sendfeedback_get/<id>',views.sendfeedback_get),
    path('sendfeedback_post/',views.sendfeedback_post),
    path('teamleaderviewstatus/',views.teamleaderviewstatus),
    path('viewworkandfeedback/',views.viewworkandfeedback),
    path('deletefeedback/<id>',views.deletefeedback),
    path('viewmemberfeedback/<id>',views.viewmemberfeedback),
    path('assignworktomember_get/<id>',views.assignworktomember_get),
    path('assignworktomember_post/',views.assignworktomember_post),
    path('updatestatus_get/<id>',views.updatestatus_get),
    path('updatestatus_post/',views.updatestatus_post),
    path('teamleaderchangepassword_get/',views.teamleaderchangepassword_get),
    path('teamleaderchangepassword_post/',views.teamleaderchangepassword_post),
    path('teamleader_stress_report_get/',views.teamleader_stress_report_get),

# ========================================================== Team member APP=================================================
    path('mobileteammemberlogin_post/',views.mobileteammemberlogin_post),
    path('teammemberviewprofile_post/',views.teammemberviewprofile_post),
    path('teammemberchangepassword_post/',views.teammemberchangepassword_post),
    path('mobileviewteamleader/',views.mobileviewteamleader),
    path('mobileviewfeedback/',views.mobileviewfeedback),
    path('mobileupdatestatus/',views.mobileupdatestatus),
    path('mobileviewwork/',views.mobileviewwork),
    path('mobileeditprofile/',views.mobileeditprofile),
    path('changePasswordflutter/',views.changePasswordflutter),
    path('forgotpasswordflutter/',views.forgotpasswordflutter),
    path('verifyOtpflutterPost/',views.verifyOtpflutterPost),
    path('mobileemotion_predict_post/',views.mobileemotion_predict_post),
    path('mobileemotion_post/',views.mobileemotion_post),
    path('mobilethermalpredict_post/',views.mobilethermalpredict_post,name='mobilethermalpredict_post'),
]


