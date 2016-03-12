FROM ubuntu:14.04

RUN apt-get update && \ 
	apt-get upgrade -y && \
	apt-get install -y wget curl locales git python python-pip python-dev \
    libffi-dev libssl-dev libxml2-dev libxslt-dev libxslt1-dev zlib1g-dev \
    openjdk-7-jdk libpq-dev libncurses5-dev libsasl2-dev gcc python3-dev \
    python3-pip software-properties-common

RUN mkdir /www/ && git clone https://github.com/rtfd/readthedocs.org.git /www
WORKDIR /www
RUN pip install --upgrade pip && ln -sf /usr/local/bin/pip /usr/bin/pip
RUN pip install -r requirements.txt && \
    easy_install3 pip && pip3 install virtualenv
RUN ./manage.py migrate && \
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', 'admin')" | ./manage.py shell && \
    echo "yes" | ./manage.py collectstatic && \
    ./manage.py loaddata test_data

# RUN pip install -U virtualenv # it'll cause a bug if we don't upgrade

# private repo
RUN echo "ALLOW_PRIVATE_REPOS=True\nACCOUNT_EMAIL_VERIFICATION='none'" > \
    /www/readthedocs/settings/local_settings.py

CMD ["cd /www && ./manage.py runserver 0.0.0.0:8000"]