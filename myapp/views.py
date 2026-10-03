import os
import smtplib
import calendar
from collections import Counter
from datetime import date, datetime, timedelta
import json

import cv2
from django.contrib.auth import authenticate, login, logout
from django.core.mail import send_mail
from django.db.models import Avg, Count, Q
from django.shortcuts import render, redirect
from django.contrib.auth.models import User,Group
from django.contrib import messages
from django.views.decorators.csrf import csrf_exempt
import numpy as np
from sympy.printing.tests.test_tensorflow import tf

from myapp.thermal_model import predict_thermal_stress
from .models import emotion
from django.utils import timezone
from django.contrib.auth.models import User
from .fer_prediction import predict_emotion
from myapp.models import *
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, JsonResponse
from stress_monitoring import settings

# emotions that count as "stress related"
STRESS_EMOTIONS = ['angry', 'fear', 'sad', 'disgust']


def _js(data):
    """JSON for embedding inside a <script> block ({{ x|safe }})."""
    return json.dumps(data).replace('<', '\\u003c')


def login_get(request):
    return render(request,'login.html')

def login_post(request):
    username=request.POST['username']
    password=request.POST['password']

    if not username or not password:
        return redirect('/myapp/login_get/')
    user=authenticate(request,username=username,password=password)

    if user is not None:
        login(request,user)

        if user.groups.filter(name='admin').exists():
            return redirect('/myapp/adminhome_get/')
        elif user.groups.filter(name='hr').exists():
            login(request, user)
            return redirect('/myapp/hrhome_get/')
        elif user.groups.filter(name='teamleader').exists():
            return redirect('/myapp/teamleaderhome_get/')
        else:
            return redirect('/myapp/login_get/')

    else:
        return redirect('/myapp/login_get/')

def logout_get(request):
    logout(request)
    return redirect('/myapp/login_get/')

def getdob():
    today = date.today()
    dob = date(today.year - 18, today.month, today.day)
    return str(dob)

def forget_get(request):
    return render(request,'forgetpassword.html')

import random
import string
import smtplib


def generate_password(length=10):
    if length < 4:
        length = 4  # need room for at least one of each required character type

    uppercase = string.ascii_uppercase
    lowercase = string.ascii_lowercase
    digits = string.digits
    symbols = "!@#$%^&*"

    password_chars = [
        random.choice(uppercase),
        random.choice(lowercase),
        random.choice(digits),
        random.choice(symbols),
    ]

    all_chars = uppercase + lowercase + digits + symbols
    password_chars += [random.choice(all_chars) for _ in range(length - 4)]

    random.shuffle(password_chars)
    return ''.join(password_chars)


def forgetpass_post(request):
    email = request.POST['email']

    if User.objects.filter(username=email).exists():
        new_pass = generate_password(10)

        user = User.objects.get(username=email)
        user.set_password(new_pass)
        user.save()

        try:
            server = smtplib.SMTP('smtp.gmail.com', 587)
            server.starttls()
            server.login("ordreponline@gmail.com", "rlluwdolngvoozvy")  # App Password
            subject = "Reset Password"
            body = "Hello,\n\nYour new password is: " + new_pass + "\n\nPlease log in and change it as soon as possible."
            msg = f"Subject: {subject}\n\n{body}"
            server.sendmail("ordreponline@gmail.com", email, msg)
            server.quit()
        except Exception:
            messages.warning(request, 'Could not send email. Please try again later.')
            return redirect('/myapp/forget_get/')

        messages.success(request, 'A new password has been sent to your email.')
        return redirect('/myapp/login_get/')

    else:
        messages.warning(request, 'Email does not exist')
        return redirect('/myapp/forget_get/')
# =======================================admin==========================================================================================================
@login_required(login_url='/myapp/login_get/')
def adminhome_get(request):
    return render(request,'admin/home.html')

@login_required(login_url='/myapp/login_get/')
def addhr_get(request):
    dob = getdob()
    return render(request,'admin/addhr.html',{'dob':dob})

@login_required(login_url='/myapp/login_get/')
def addhr_post(request):
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    photo=request.FILES['photo']
    gender=request.POST['gender']
    dob=request.POST['dob']
    qualification=request.POST['qualification']
    password=request.POST['password']

    a=User.objects.create_user(username=email,password=password,email=email)

    a.groups.add(Group.objects.get(name='hr'))

    obj=Hr()
    obj.name=name
    obj.phone=phone
    obj.email=email
    obj.photo=photo
    obj.gender=gender
    obj.dob=dob
    obj.qualification=qualification
    obj.LOGIN=a
    obj.save()

    return redirect('/myapp/viewhr_get/')

@login_required(login_url='/myapp/login_get/')
def viewhr_get(request):
    a=Hr.objects.all()
    return render(request,'admin/viewhr.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def delete_hr(request,id):
    ob=User.objects.get(id=id)
    ob.delete()
    return redirect("/myapp/viewhr_get/")

@login_required(login_url='/myapp/login_get/')
def edithr_get(request,id):
    a=Hr.objects.get(id=id)
    dob = getdob()
    return render(request,'admin/edithr.html',{'data':a,'dob':dob})

@login_required(login_url='/myapp/login_get/')
def edithr_post(request):
    id = request.POST['id']

    a = Hr.objects.get(id=id)

    a.name = request.POST['name']
    a.email = request.POST['email']
    a.phone = request.POST['phone']
    a.gender = request.POST['gender']
    a.dob = request.POST['dob']
    a.qualification = request.POST['qualification']

    if 'photo' in request.FILES:
        a.photo = request.FILES['photo']

    a.save()

    return redirect('/myapp/viewhr_get/')

@login_required(login_url='/myapp/login_get/')
def adminviewwork_get(request):
    a=Work.objects.all()
    res=[]
    for i in a:
        oba = Assign.objects.filter(WORK__id=i.id)
        i.tl="Not Assigned"
        if len(oba)>0:
            i.tl = oba[0].TEAM_LEADER.name
        res.append(i)
    return render(request,'admin/viewwork.html',{'data':res})

@login_required(login_url='/myapp/login_get/')
def adminchangepassword_get(request):
    return render(request,'admin/changepassword.html')

@login_required(login_url='/myapp/login_get/')
def adminchangepassword_post(request):
   current=request.POST['current']
   new=request.POST['new']
   confirm=request.POST['confirm']
   a=request.user
   if a.check_password(current):
       if new==confirm:
           a.set_password(new)
           a.save()
           return redirect('/myapp/login_get/')
       else:
           messages.warning(request,'new and confirm must be same')
           return redirect('/myapp/changepassword_get/')
   else:
       messages.warning(request,'wrong password')
       return redirect('/myapp/changepassword_get/')

@login_required(login_url='/myapp/login_get/')
def adminviewteammember(request,id):
    a=Assign_sub.objects.filter(ASSIGN__TEAM_LEADER__id=id)
    return render(request,'admin/viewteammember.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def adminviewteamleader(request):
    a=Team_leader.objects.all()
    return render(request,'admin/viewteamleader.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def adminviewfeedback(request):
    a=Feedback.objects.all()

    return render(request,'admin/viewfeedback.html',{'data':a})

def admin_stress_report_get(request):

    reports = ThermalStress.objects.all().order_by(
        '-date',
        '-time'
    )

    total_reports = reports.count()

    stress_count = reports.filter(
        stress_status="STRESS"
    ).count()

    normal_count = reports.filter(
        stress_status="NON-STRESS"
    ).count()

    return render(
        request,
        'admin/stress_report.html',
        {
            'reports': reports,
            'total_reports': total_reports,
            'stress_count': stress_count,
            'normal_count': normal_count
        }
    )
# ===================================HR=============================================================================================================
@login_required(login_url='/myapp/login_get/')
def hrhome_get(request):
    a=Hr.objects.get(LOGIN=request.user)
    return render(request,'hr/home.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def hrviewprofile_get(request):
    a=Hr.objects.get(LOGIN=request.user)
    return render(request,'hr/viewprofile.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def addteamleader_get(request):
    dob=getdob()
    return render(request,'hr/addteamleader.html',{"dob":dob})

@login_required(login_url='/myapp/login_get/')
def addteamleader_post(request):
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    photo = request.FILES['photo']
    gender = request.POST['gender']
    dob = request.POST['dob']
    qualification = request.POST['qualification']
    experience = request.POST['experience']
    password = request.POST['password']

    b=User.objects.create_user(username=email,password=password,email=email)
    b.groups.add(Group.objects.get(name='teamleader'))
    obj=Team_leader()
    obj.name=name
    obj.email=email
    obj.phone=phone
    obj.photo=photo
    obj.gender=gender
    obj.dob=dob
    obj.qualification=qualification
    obj.experience=experience
    obj.HR=Hr.objects.get(LOGIN=request.user)
    obj.LOGIN=b
    obj.save()

    return redirect('/myapp/viewteamleader_get/')

@login_required(login_url='/myapp/login_get/')
def viewteamleader_get(request):
    a=Team_leader.objects.all()
    return render(request,'hr/viewteamleader.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def delete_teamleader(request,id):
    ob=User.objects.get(id=id)
    ob.delete()
    return  redirect('/myapp/viewteamleader_get/')

@login_required(login_url='/myapp/login_get/')
def editteamleader_get(request,id):
    a=Team_leader.objects.get(id=id)
    dob = getdob()

    return render(request,'hr/editteamleader.html',{'data':a,'dob':dob})

@login_required(login_url='/myapp/login_get/')
def editteamleader_post(request):
    id=request.POST['id']

    a=Team_leader.objects.get(id=id)

    a.name=request.POST['name']
    a.email=request.POST['email']
    a.phone=request.POST['phone']
    a.gender=request.POST['gender']
    a.dob=request.POST['dob']
    a.qualification=request.POST['qualification']
    a.experience=request.POST['experience']

    if 'photo' in request.FILES:
        a.photo=request.FILES['photo']

    a.save()
    return  redirect('/myapp/viewteamleader_get/')

@login_required(login_url='/myapp/login_get/')
def addteammember_get(request):
    data=Team_leader.objects.all()
    dob = getdob()
    return render(request,'hr/addteammember.html',{'data':data,'dob':dob})

@login_required(login_url='/myapp/login_get/')
def addteammember_post(request):
    name = request.POST['name']
    email = request.POST['email']
    phone = request.POST['phone']
    photo = request.FILES['photo']
    gender = request.POST['gender']
    dob = request.POST['dob']
    qualification = request.POST['qualification']
    experience = request.POST['experience']
    password = request.POST['password']
    teamleader = request.POST['teamleader']

    a=User.objects.create_user(username=email,password=password,email=email)
    a.groups.add(Group.objects.get(name='teammember'))

    obj=Team_member()
    obj.name=name
    obj.email=email
    obj.phone=phone
    obj.photo=photo
    obj.gender=gender
    obj.dob=dob
    obj.qualification=qualification
    obj.experience=experience
    obj.Team_leader=Team_leader.objects.get(id=teamleader)
    obj.LOGIN=a
    obj.save()

    return redirect('/myapp/viewteammember_get/')

@login_required(login_url='/myapp/login_get/')
def viewteammember_get(request):
    a=Team_member.objects.all()
    return render(request,'hr/viewteammember.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def editteammember_get(request,id):
    a=Team_member.objects.get(id=id)
    dob = getdob()
    return render(request,'hr/editteammember.html',{'data':a,'dob':dob})

@login_required(login_url='/myapp/login_get/')
def editteammember_post(request):
    id=request.POST['id']

    a=Team_member.objects.get(id=id)

    a.name = request.POST['name']
    a.email = request.POST['email']
    a.phone = request.POST['phone']
    a.gender = request.POST['gender']
    a.dob = request.POST['dob']
    a.qualification = request.POST['qualification']
    a.experience = request.POST['experience']

    if 'photo' in request.FILES:
        a=request.POST['photo']

    a.save()

    return redirect('/myapp/viewteammember_get/')

@login_required(login_url='/myapp/login_get/')
def delete_teammember(request,id):
    ob=User.objects.get(id=id)
    ob.delete()
    return  redirect('/myapp/viewteammember_get/')

@login_required(login_url='/myapp/login_get/')
def addwork_get(request):
    return render(request,'hr/addwork.html')

@login_required(login_url='/myapp/login_get/')
def addwork_post(request):
    date=request.POST['date']
    deadline=request.POST['deadline']
    worktitle=request.POST['worktitle']
    work_description=request.POST['workdescription']

    obj=Work()
    obj.date=date
    obj.deadline=deadline
    obj.worktitle=worktitle
    obj.work_description=work_description
    obj.status='pending'
    obj.HR=Hr.objects.get(LOGIN=request.user)
    obj.save()

    return redirect('/myapp/hrviewwork_get/')

@login_required(login_url='/myapp/login_get/')
def hrviewwork_get(request):
    a = Work.objects.all()

    for i in a:
        i.is_assigned = Assign.objects.filter(WORK=i).exists()

    return render(request, 'hr/viewwork.html', {'data': a})

@login_required(login_url='/myapp/login_get/')
def editwork_get(request,id):
    a=Work.objects.get(id=id)
    return render(request,'hr/editwork.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def editwork_post(request):
    id=request.POST['id']

    a=Work.objects.get(id=id)

    a.date=request.POST['date']
    a.deadline=request.POST['deadline']
    a.worktitle=request.POST['worktitle']
    a.work_description=request.POST['work_description']
    a.save()

    return redirect('/myapp/hrviewwork_get/')

@login_required(login_url='/myapp/login_get/')
def deletework_get(request,id):
    ob=Work.objects.get(id=id)
    ob.delete()
    return redirect('/myapp/hrviewwork_get/')

@login_required(login_url='/myapp/login_get/')
def assignwork_get(request):
    a=Team_leader.objects.all()
    b=Work.objects.all()
    return render(request,'hr/assign.html',{'data':a,'work':b})

@login_required(login_url='/myapp/login_get/')
def assignwork_post(request):
    work=request.POST['work']
    team_leader=request.POST['team_leader']
    date=request.POST['date']

    a=Assign()
    a.WORK=Work.objects.get(id=work)
    a.TEAM_LEADER=Team_leader.objects.get(id=team_leader)
    a.date=date
    a.save()

    return redirect('/myapp/viewassignedwork_get/')

@login_required(login_url='/myapp/login_get/')
def viewassignedwork_get(request):
    a=Assign.objects.all()
    return render(request,'hr/viewassignedwork.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def deleteassignedwork_get(request,id):
    ob=Assign.objects.get(id=id)
    ob.delete()
    return redirect('/myapp/viewassignedwork_get/')

@login_required(login_url='/myapp/login_get/')
def hrviewfeedback(request, id):
    a = Feedback.objects.filter(ASSIGN_SUB_id=id)

    return render(request, 'hr/viewfeedback.html', {'data': a})

@login_required(login_url='/myapp/login_get/')
def viewteammemberswork(request, id):
    a = Assign_sub.objects.filter(ASSIGN_id=id)
    return render(request, 'hr/viewteamwork.html', {'data': a})

@login_required(login_url='/myapp/login_get/')
def hrchangepassword_get(request):
    return render(request,'hr/changepassword.html')

@login_required(login_url='/myapp/login_get/')
def hrchangepassword_post(request):
   current=request.POST['current']
   new=request.POST['new']
   confirm=request.POST['confirm']
   a=request.user
   if a.check_password(current):
       if new==confirm:
           a.set_password(new)
           a.save()
           return redirect('/myapp/login_get/')
       else:
           messages.warning(request,'new and confirm must be same')
           return redirect('/myapp/changepassword_get/')
   else:
       messages.warning(request,'wrong password')
       return redirect('/myapp/changepassword_get/')

def hr_stress_report_get(request):

    hr = Hr.objects.get(LOGIN=request.user)

    reports = ThermalStress.objects.all().order_by(
        '-date',
        '-time'
    )

    total_reports = reports.count()

    stress_count = reports.filter(
        stress_status="STRESS"
    ).count()

    normal_count = reports.filter(
        stress_status="NON-STRESS"
    ).count()

    return render(
        request,
        'hr/stress_report.html',
        {
            'hr': hr,
            'reports': reports,
            'total_reports': total_reports,
            'stress_count': stress_count,
            'normal_count': normal_count
        }
    )

# ======================================= Team_leader ========================================================================
@login_required(login_url='/myapp/login_get/')
def teamleaderhome_get(request):
    a=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/home.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def teamleaderviewprofile(request):
    a = Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/viewprofile.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def viewteammember(request):
    a=Team_member.objects.all()
    b=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/viewteammember.html',{'data':a,'leader':b})

@login_required(login_url='/myapp/login_get/')
def viewassignedwork(request):
    team_leader = Team_leader.objects.get(LOGIN=request.user)
    a = Assign.objects.filter(TEAM_LEADER=team_leader)
    b=Team_leader.objects.get(LOGIN=request.user)
    return render(request, 'team_leader/viewassignedwork.html', {'data': a,'leader':b})

@login_required(login_url='/myapp/login_get/')
def assignworktomember_get(request, id):

    a = Team_member.objects.filter(
        Team_leader__LOGIN=request.user
    )
    b=Team_leader.objects.get(LOGIN=request.user)

    work = Assign.objects.get(
        id=id,
        TEAM_LEADER__LOGIN=request.user
    )

    return render(
        request,
        'team_leader/assigntoteammember.html',
        {
            'data': a,
            'work': work,
            'leader':b

        }
    )

@login_required(login_url='/myapp/login_get/')
def assignworktomember_post(request):

    team_member = request.POST['team_member']
    assign_id = request.POST['assign_id']

    if Assign_sub.objects.filter(TEAM_MEMBER_id=team_member,ASSIGN_id=assign_id).exists():
        return HttpResponse('alredy added')
    else:
        obj = Assign_sub()

        obj.date = date.today()
        obj.status = 'pending'

        obj.ASSIGN = Assign.objects.get(
            id=assign_id,
            TEAM_LEADER__LOGIN=request.user
        )

        obj.TEAM_MEMBER = Team_member.objects.get(
            id=team_member,
            Team_leader__LOGIN=request.user
        )

        obj.save()

        return redirect('/myapp/viewworkandfeedback/')



@login_required(login_url='/myapp/login_get/')
def viewworkassignedtomember_get(request,id):
    a = Assign_sub.objects.filter(ASSIGN_id=id)
    b=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/viewassignedmembers.html',{'data':a,'leader':b})

@login_required(login_url='/myapp/login_get/')
def sendfeedback_get(request,id):
    a=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/sendfeedback.html',{'id':id,'leader':a})

@login_required(login_url='/myapp/login_get/')
def sendfeedback_post(request):
    feedback = request.POST['feedback']
    id = request.POST['id']

    obj = Feedback()
    obj.date = date.today()
    obj.feedback = feedback
    obj.ASSIGN_SUB = Assign_sub.objects.get(id=id)
    obj.save()

    return redirect('/myapp/viewworkandfeedback/')
@login_required(login_url='/myapp/login_get/')
def teamleaderviewstatus(request):
    a=Team_leader.objects.get(LOGIN=request.user)
    data = Assign_sub.objects.filter(ASSIGN__TEAM_LEADER__LOGIN=request.user)

    for i in data:
        i.feedback_exists = Feedback.objects.filter(ASSIGN_SUB=i).exists()

    return render(request,'team_leader/viewstatus.html',{'data': data,'leader':a})

@login_required(login_url='/myapp/login_get/')
def viewworkandfeedback(request):
    a=Assign_sub.objects.filter(ASSIGN__TEAM_LEADER__LOGIN=request.user)
    b=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/viewworkfeedback.html',{'data':a,'pro':b})

@login_required(login_url='/myapp/login_get/')
def viewmemberfeedback(request, id):
    a = Feedback.objects.filter(ASSIGN_SUB_id=id)
    b=Team_leader.objects.get(LOGIN=request.user)
    return render(request,'team_leader/viewfeedback.html',{'data': a,'pro':b})

@login_required(login_url='/myapp/login_get/')
def deletefeedback(request, id):
    obj = Feedback.objects.get(id=id)
    obj.delete()
    return redirect('/myapp/viewworkandfeedback/')

@login_required(login_url='/myapp/login_get/')
def updatestatus_get(request,id):
    a=Assign.objects.get(id=id)
    return render(request,'team_leader/updateworkstatus.html',{'data':a})

@login_required(login_url='/myapp/login_get/')
def updatestatus_post(request):
    id=request.POST['id']
    status=request.POST['status']

    a=Assign.objects.get(id=id)
    a.status=status
    a.save()

    return redirect('/myapp/viewassignedwork/')

@login_required(login_url='/myapp/login_get/')
def teamleaderchangepassword_get(request):
    return render(request,'team_leader/changepassword.html')

@login_required(login_url='/myapp/login_get/')
def teamleaderchangepassword_post(request):
   current=request.POST['current']
   new=request.POST['new']
   confirm=request.POST['confirm']
   a=request.user
   if a.check_password(current):
       if new==confirm:
           a.set_password(new)
           a.save()
           return redirect('/myapp/login_get/')
       else:
           messages.warning(request,'new and confirm must be same')
           return redirect('/myapp/changepassword_get/')
   else:
       messages.warning(request,'wrong password')
       return redirect('/myapp/changepassword_get/')

def teamleader_stress_report_get(request):

    teamleader = Team_leader.objects.get(
        LOGIN=request.user
    )

    members = Team_member.objects.filter(
        Team_leader=teamleader
    )

    reports = ThermalStress.objects.filter(
        LOGIN__in=members.values_list('LOGIN', flat=True)
    ).order_by(
        '-date',
        '-time'
    )

    total_reports = reports.count()

    stress_count = reports.filter(
        stress_status="STRESS"
    ).count()

    normal_count = reports.filter(
        stress_status="NON-STRESS"
    ).count()

    return render(
        request,
        'team_leader/stress_report.html',
        {
            'teamleader': teamleader,
            'members': members,
            'reports': reports,
            'total_reports': total_reports,
            'stress_count': stress_count,
            'normal_count': normal_count
        }
    )
    # =============================================================Team_member APP=====================================================

def mobileteammemberlogin_post(request):
    username = request.POST['username']
    password = request.POST['password']

    if not username or not password:
        return JsonResponse({'status':'no'})
    user = authenticate(request, username=username, password=password)
    if user is not None:
        login(request, user)

        if user.groups.filter(name='teammember').exists():
            return JsonResponse({'status':'ok','lid':str(user.id)})

        else:
            return JsonResponse({'status':'no'})

    else:
        return JsonResponse({'status':'no'})

def teammemberviewprofile_post(request):
    lid=request.POST['lid']
    a=Team_member.objects.get(LOGIN_id=lid)
    return JsonResponse({
        'status':'ok',
        'name':a.name,
        'email':a.email,
        'phone':a.phone,
        'photo': request.build_absolute_uri(a.photo.url),
        'gender':a.gender,
        'dob':a.dob,
        'qualification':a.qualification,
        'experience':a.experience,
    })


def teammemberchangepassword_post(request):
   id=request.POST['lid']
   current=request.POST['current']
   new=request.POST['new']
   confirm=request.POST['confirm']
   a=User.objects.get(id=id)
   if a.check_password(current):
       if new==confirm:
           a.set_password(new)
           a.save()
           return JsonResponse({'status':'ok'})
       else:
           return JsonResponse({'status':'no'})
   else:
       return JsonResponse({'status':'no'})



def mobileviewteamleader(request):
    id=request.POST['lid']
    tl=Team_member.objects.get(LOGIN_id=id).Team_leader.id
    a=Team_leader.objects.filter(id=tl)
    l=[]
    for i in a:
        l.append({
            'id':i.id,
            'name':i.name,
            'email':i.email,
            'phone':i.phone,
            'photo': request.build_absolute_uri(i.photo.url),
            'gender':i.gender,
            'dob':i.dob,
        })
    return JsonResponse({'status':'ok','data':l})

def mobileviewfeedback(request):

    lid = request.POST['lid']

    a = Feedback.objects.filter(
        ASSIGN_SUB__TEAM_MEMBER__LOGIN_id=lid
    )

    l = []

    for i in a:

        l.append({
            'id': i.id,
            'date': i.date,
            'feedback': i.feedback,
            'worktitle': i.ASSIGN_SUB.ASSIGN.WORK.worktitle,
            'teamleader': i.ASSIGN_SUB.ASSIGN.TEAM_LEADER.name,
        })

    return JsonResponse({
        'status': 'ok',
        'data': l
    })

def mobileupdatestatus(request):

    id = request.POST['id']
    status = request.POST['status']

    a = Assign_sub.objects.get(id=id)

    a.status = status
    a.save()

    return JsonResponse({
        'status': 'ok',
        'message': 'Status updated successfully'
    })

def mobileviewwork(request):

    lid = request.POST['lid']

    a = Assign_sub.objects.filter(
        TEAM_MEMBER__LOGIN_id=lid
    )

    l = []

    for i in a:

        feedback = Feedback.objects.filter(
            ASSIGN_SUB=i
        ).last()

        if feedback:
            feedback_text = feedback.feedback
        else:
            feedback_text = 'No feedback'

        l.append({
            'id': i.id,
            'date': i.date,
            'status': i.status,
            'worktitle': i.ASSIGN.WORK.worktitle,
            'work_description': i.ASSIGN.WORK.work_description,
            'teamleader': i.ASSIGN.TEAM_LEADER.name,
            'feedback': feedback_text,
        })

    return JsonResponse({
        'status': 'ok',
        'data': l
    })

def mobileeditprofile(request):

    id = request.POST['lid']

    a = Team_member.objects.get(
        LOGIN_id=id
    )

    a.name = request.POST['name']
    a.email = request.POST['email']
    a.phone = request.POST['phone']
    a.gender = request.POST['gender']
    a.dob = request.POST['dob']
    a.qualification = request.POST['qualification']
    a.experience = request.POST['experience']

    if 'photo' in request.FILES:
        a.photo = request.FILES['photo']

    a.save()

    return JsonResponse({
        'status': 'ok',
        'message': 'Profile updated successfully'
    })

def forgotpasswordflutter(request):
    email = request.POST['email']
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Email not found'})
    otp = random.randint(100000, 999999)
    PasswordResetOTP.objects.create(email=email, otp=otp)
    send_mail('Your Verification Code',
    f'Your verification code is {otp}',
    settings.EMAIL_HOST_USER,
    [email],
    fail_silently=False)
    return JsonResponse({'status': 'ok', 'message': 'OTP sent'})

def verifyOtpflutterPost(request):
    email = request.POST['email']
    entered_otp=request.POST['entered_otp']
    otp_obj = PasswordResetOTP.objects.filter(email=email).latest('created_at')
    if otp_obj.otp == entered_otp:
        return JsonResponse({'status': 'ok'})
    else:
        return JsonResponse({'status': 'error'})

def changePasswordflutter(request):
    email = request.POST['email']
    newpassword = request.POST['newPassword']
    confirmPassword = request.POST['confirmPassword']
    if newpassword == confirmPassword:
        try:
            user = User.objects.get(email=email)
            user.set_password(confirmPassword)
            user.save()
            return JsonResponse({'status': 'ok'})
        except User.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'User not found'})
    else:
        return JsonResponse({'status': 'error', 'message': 'Passwords do not match'})



def mobileemotion_predict_post(request):

    if request.method == 'POST':

        try:

            if 'image' not in request.FILES:

                return JsonResponse({
                    'status': 'no',
                    'message': 'Image not found'
                })


            image = request.FILES['image']


            emotion_name, score = predict_emotion(
                image
            )


            if emotion_name is None:

                return JsonResponse({
                    'status': 'no',
                    'message': 'No face detected'
                })


            return JsonResponse({

                'status': 'ok',

                'emotion':
                    emotion_name,

                'score':
                    round(score, 4)

            })


        except Exception as e:

            return JsonResponse({

                'status': 'no',

                'message':
                    str(e)

            })


    return JsonResponse({

        'status': 'no'

    })

def mobileemotion_post(request):

    if request.method == 'POST':

        try:

            emotion_name = request.POST.get(
                'emotion'
            )

            score = request.POST.get(
                'score'
            )

            lid = request.POST.get(
                'lid'
            )


            if not emotion_name or not score or not lid:

                return JsonResponse({

                    'status': 'no',

                    'message':
                        'Missing data'

                })


            user = User.objects.get(
                id=lid
            )


            a = emotion()

            a.emotion = emotion_name

            a.score = float(score)

            a.date = timezone.localdate()

            a.LOGIN = user

            a.save()


            return JsonResponse({

                'status': 'ok'

            })


        except User.DoesNotExist:

            return JsonResponse({

                'status': 'no',

                'message':
                    'User not found'

            })


        except Exception as e:

            return JsonResponse({

                'status': 'no',

                'message':
                    str(e)

            })


    return JsonResponse({

        'status': 'no'

    })










# ============================================================
# THERMAL MODEL SETTINGS
# ============================================================

THERMAL_WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_best.weights.h5"

IMG_SIZE = 160

THRESHOLD = 0.50

thermal_model = None


# ============================================================
# CREATE THERMAL MODEL
# ============================================================

def create_thermal_model():

    print()
    print("==============================================")
    print("CREATING THERMAL MODEL")
    print("==============================================")

    # --------------------------------------------------------
    # INPUT
    # --------------------------------------------------------

    inputs = tf.keras.Input(
        shape=(IMG_SIZE, IMG_SIZE, 3),
        name="thermal_input"
    )

    # --------------------------------------------------------
    # EFFICIENTNET B0
    # --------------------------------------------------------

    base_model = tf.keras.applications.EfficientNetB0(
        include_top=False,
        weights="imagenet",
        input_shape=(IMG_SIZE, IMG_SIZE, 3)
    )

    base_model._name = "efficientnetb0"

    base_model.trainable = True

    # --------------------------------------------------------
    # FINE TUNING
    # --------------------------------------------------------

    fine_tune_from = int(
        len(base_model.layers) * 0.60
    )

    for i, layer in enumerate(base_model.layers):

        if i < fine_tune_from:
            layer.trainable = False
        else:
            layer.trainable = True

        if isinstance(
            layer,
            tf.keras.layers.BatchNormalization
        ):
            layer.trainable = False

    # --------------------------------------------------------
    # RESTORE 255
    # --------------------------------------------------------

    x = tf.keras.layers.Rescaling(
        255.0,
        name="restore_255"
    )(inputs)

    # --------------------------------------------------------
    # EFFICIENTNET
    # --------------------------------------------------------

    x = base_model(x)

    # --------------------------------------------------------
    # GLOBAL AVERAGE POOLING
    # --------------------------------------------------------

    x = tf.keras.layers.GlobalAveragePooling2D(
        name="global_average_pooling"
    )(x)

    # --------------------------------------------------------
    # BATCH NORMALIZATION
    # --------------------------------------------------------

    x = tf.keras.layers.BatchNormalization(
        name="head_batch_norm"
    )(x)

    # --------------------------------------------------------
    # DENSE 256
    # --------------------------------------------------------

    x = tf.keras.layers.Dense(
        256,
        activation="relu",
        name="dense_256"
    )(x)

    # --------------------------------------------------------
    # DROPOUT 45
    # --------------------------------------------------------

    x = tf.keras.layers.Dropout(
        0.45,
        name="dropout_45"
    )(x)

    # --------------------------------------------------------
    # DENSE 64
    # --------------------------------------------------------

    x = tf.keras.layers.Dense(
        64,
        activation="relu",
        name="dense_64"
    )(x)

    # --------------------------------------------------------
    # DROPOUT 30
    # --------------------------------------------------------

    x = tf.keras.layers.Dropout(
        0.30,
        name="dropout_30"
    )(x)

    # --------------------------------------------------------
    # OUTPUT
    # --------------------------------------------------------

    outputs = tf.keras.layers.Dense(
        1,
        activation="sigmoid",
        name="stress_output"
    )(x)

    # --------------------------------------------------------
    # COMPLETE MODEL
    # --------------------------------------------------------

    model = tf.keras.Model(
        inputs=inputs,
        outputs=outputs
    )

    print()
    print("Model created successfully.")

    print(
        "Input shape:",
        model.input_shape
    )

    print(
        "Output shape:",
        model.output_shape
    )

    print(
        "Layers:",
        len(model.layers)
    )

    return model


# ============================================================
# LOAD THERMAL MODEL
# ============================================================

def load_thermal_model():

    global thermal_model

    # --------------------------------------------------------
    # Already loaded
    # --------------------------------------------------------

    if thermal_model is not None:

        return thermal_model

    print()
    print("==============================================")
    print("LOADING THERMAL MODEL")
    print("==============================================")

    print()
    print("Weights path:")

    print(
        THERMAL_WEIGHTS_PATH
    )

    # --------------------------------------------------------
    # Check weights file
    # --------------------------------------------------------

    if not os.path.exists(
        THERMAL_WEIGHTS_PATH
    ):

        print()
        print("==============================================")
        print("THERMAL WEIGHTS FILE NOT FOUND")
        print("==============================================")

        print(
            THERMAL_WEIGHTS_PATH
        )

        return None

    print()
    print(
        "Weights file exists:",
        True
    )

    print(
        "Weights size:",
        os.path.getsize(
            THERMAL_WEIGHTS_PATH
        ),
        "bytes"
    )

    try:

        # ----------------------------------------------------
        # Create architecture
        # ----------------------------------------------------

        model = create_thermal_model()

        # ----------------------------------------------------
        # Load trained weights
        # ----------------------------------------------------

        print()
        print("==============================================")
        print("LOADING TRAINED WEIGHTS")
        print("==============================================")

        model.load_weights(
            THERMAL_WEIGHTS_PATH,
            by_name=True,
            skip_mismatch=False
        )

        print()
        print("==============================================")
        print("THERMAL WEIGHTS LOADED SUCCESSFULLY")
        print("==============================================")

        print(
            "Input:",
            model.input_shape
        )

        print(
            "Output:",
            model.output_shape
        )

        print(
            "Layers:",
            len(model.layers)
        )

        # ----------------------------------------------------
        # Save model in memory
        # ----------------------------------------------------

        thermal_model = model

        return thermal_model

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL MODEL LOAD ERROR")
        print("==============================================")

        print(
            "Error type:",
            type(e).__name__
        )

        print(
            "Error:",
            str(e)
        )

        thermal_model = None

        return None


# ============================================================
# PREPROCESS THERMAL IMAGE
# ============================================================

def preprocess_thermal_frame(frame):

    # --------------------------------------------------------
    # Resize
    # --------------------------------------------------------

    frame = cv2.resize(
        frame,
        (IMG_SIZE, IMG_SIZE)
    )

    # --------------------------------------------------------
    # Convert to float32
    # --------------------------------------------------------

    frame = frame.astype(
        np.float32
    )

    # --------------------------------------------------------
    # Min-max normalization
    # --------------------------------------------------------

    image_min = np.min(
        frame
    )

    image_max = np.max(
        frame
    )

    if image_max > image_min:

        frame = (
            frame - image_min
        ) / (
            image_max - image_min
        )

    else:

        frame = frame / 255.0

    # --------------------------------------------------------
    # Add batch dimension
    # --------------------------------------------------------

    frame = np.expand_dims(
        frame,
        axis=0
    )

    return frame


# ============================================================
# PREDICT THERMAL STRESS
# ============================================================

def predict_thermal_stress(frame):

    # --------------------------------------------------------
    # Load model
    # --------------------------------------------------------

    model = load_thermal_model()

    if model is None:

        return (
            None,
            None,
            "Thermal model could not be loaded"
        )

    try:

        # ----------------------------------------------------
        # BGR -> RGB
        # ----------------------------------------------------

        frame = cv2.cvtColor(
            frame,
            cv2.COLOR_BGR2RGB
        )

        # ----------------------------------------------------
        # Preprocess
        # ----------------------------------------------------

        image = preprocess_thermal_frame(
            frame
        )

        # ----------------------------------------------------
        # Prediction
        # ----------------------------------------------------

        prediction = model.predict(
            image,
            verbose=0
        )

        score = float(
            prediction[0][0]
        )

        # ----------------------------------------------------
        # Stress classification
        # ----------------------------------------------------

        if score >= THRESHOLD:

            status = "STRESS"

        else:

            status = "NON-STRESS"

        print()
        print("==============================================")
        print("THERMAL PREDICTION")
        print("==============================================")

        print(
            "Score:",
            score
        )

        print(
            "Status:",
            status
        )

        return (
            status,
            score,
            None
        )

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL PREDICTION ERROR")
        print("==============================================")

        print(
            "Error type:",
            type(e).__name__
        )

        print(
            "Error:",
            str(e)
        )

        return (
            None,
            None,
            str(e)
        )


# ============================================================
# MOBILE THERMAL PREDICTION
# ============================================================

def mobilethermalpredict_post(request):

    # --------------------------------------------------------
    # Check request method
    # --------------------------------------------------------

    if request.method != "POST":

        return JsonResponse({

            "status": "error",

            "message": "POST method required"

        })

    # --------------------------------------------------------
    # Get login ID
    # --------------------------------------------------------

    lid = request.POST.get(
        "lid"
    )

    if not lid:

        return JsonResponse({

            "status": "error",

            "message": "lid is required"

        })

    # --------------------------------------------------------
    # Check image
    # --------------------------------------------------------

    if "image" not in request.FILES:

        return JsonResponse({

            "status": "error",

            "message": "image is required"

        })

    try:

        # ====================================================
        # GET USER
        # ====================================================

        user = User.objects.get(
            id=lid
        )

        # ====================================================
        # READ IMAGE
        # ====================================================

        image_file = request.FILES[
            "image"
        ]

        image_bytes = image_file.read()

        image_array = np.frombuffer(
            image_bytes,
            np.uint8
        )

        frame = cv2.imdecode(
            image_array,
            cv2.IMREAD_COLOR
        )

        # ----------------------------------------------------
        # Check image
        # ----------------------------------------------------

        if frame is None:

            return JsonResponse({

                "status": "error",

                "message": "Invalid image"

            })

        # ====================================================
        # PREDICT
        # ====================================================

        stress_status, score, error = predict_thermal_stress(
            frame
        )

        # ====================================================
        # MODEL ERROR
        # ====================================================

        if error:

            return JsonResponse({

                "status": "error",

                "message": error

            })

        # ====================================================
        # SAVE RESULT
        # ====================================================

        obj = ThermalStress()

        obj.stress_status = stress_status

        obj.score = score

        obj.LOGIN = user

        obj.save()

        # ====================================================
        # RESPONSE
        # ====================================================

        return JsonResponse({

            "status": "ok",

            "stress_status": stress_status,

            "score": score

        })

    # ========================================================
    # USER NOT FOUND
    # ========================================================

    except User.DoesNotExist:

        return JsonResponse({

            "status": "error",

            "message": "User not found"

        })

    # ========================================================
    # OTHER ERROR
    # ========================================================

    except Exception as e:

        print()
        print("==============================================")
        print("THERMAL API ERROR")
        print("==============================================")

        print(
            "Error type:",
            type(e).__name__
        )

        print(
            "Error:",
            str(e)
        )

        return JsonResponse({

            "status": "error",

            "message": str(e)

        })
