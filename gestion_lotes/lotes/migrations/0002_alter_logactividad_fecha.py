# Generated by Django 5.1.1 on 2024-11-28 23:00

import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('lotes', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='logactividad',
            name='fecha',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
