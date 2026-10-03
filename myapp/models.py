from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class Hr(models.Model):
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.BigIntegerField()
    photo=models.FileField()
    gender=models.CharField(max_length=100)
    dob=models.DateField()
    qualification=models.CharField(max_length=100)
    LOGIN=models.OneToOneField(User,on_delete=models.CASCADE)

class Team_leader(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    photo = models.FileField()
    gender = models.CharField(max_length=100)
    dob = models.DateField()
    qualification = models.CharField(max_length=100)
    experience=models.CharField(max_length=100)
    HR=models.ForeignKey(Hr,on_delete=models.CASCADE)
    LOGIN = models.OneToOneField(User, on_delete=models.CASCADE)

class Team_member(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    photo = models.FileField()
    gender = models.CharField(max_length=100)
    dob = models.DateField()
    qualification = models.CharField(max_length=100)
    experience = models.CharField(max_length=100)
    Team_leader=models.ForeignKey(Team_leader,on_delete=models.CASCADE)
    LOGIN=models.OneToOneField(User, on_delete=models.CASCADE)

class Work(models.Model):
    date=models.DateField()
    deadline=models.DateField()
    worktitle=models.CharField(max_length=100)
    work_description=models.TextField()
    status=models.CharField(max_length=100)
    HR=models.ForeignKey(Hr,on_delete=models.CASCADE)

class Assign(models.Model):
    WORK=models.ForeignKey(Work,on_delete=models.CASCADE)
    TEAM_LEADER=models.ForeignKey(Team_leader,on_delete=models.CASCADE)
    date=models.DateField()
    status=models.CharField(max_length=100)

class Assign_sub(models.Model):
    date=models.DateField()
    status=models.CharField(max_length=100)
    ASSIGN=models.ForeignKey(Assign,on_delete=models.CASCADE)
    TEAM_MEMBER=models.ForeignKey(Team_member,on_delete=models.CASCADE)

class Feedback(models.Model):
    date=models.DateField()
    feedback=models.TextField()
    ASSIGN_SUB=models.ForeignKey(Assign_sub,on_delete=models.CASCADE)

class PasswordResetOTP(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

class emotion(models.Model):
    emotion=models.CharField(max_length=1000)
    score=models.FloatField()
    date=models.DateField()
    LOGIN = models.ForeignKey(User, on_delete=models.CASCADE)

class ThermalStress(models.Model):
    stress_status=models.CharField(max_length=100)
    score=models.FloatField()
    date=models.DateField(auto_now_add=True)
    time=models.TimeField(auto_now_add=True)
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)

    def __str__(self):
        return self.LOGIN.username + " - " + self.stress_status