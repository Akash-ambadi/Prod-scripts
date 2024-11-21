# temp stage
# FROM python:3.7-slim-buster  as builder
FROM 053132126130.dkr.ecr.ap-south-1.amazonaws.com/tmldockerbaseimages:python3.7  as builder


RUN apt-get update -y
RUN apt-get update --fix-missing

##for ldap lib
RUN apt-get install -y --no-install-recommends gdal-bin \
    gcc \
    libpq-dev \
    python-dev

RUN apt-get install -y --no-install-recommends gdal-bin \
    libldap2-dev \
    libsasl2-dev \
    ldap-utils \
    tox \
    lcov \
    valgrind \
    libpq-dev \
    gcc    

WORKDIR /code

# Allows docker to cache installed dependencies between builds
COPY ./requirements.txt requirements.txt
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /code/wheels -r requirements.txt




#final stage 
# FROM python:3.7-slim-buster
FROM 053132126130.dkr.ecr.ap-south-1.amazonaws.com/tmldockerbaseimages:python3.7


ARG UNAME=ubuntu
ARG UID=1001
ARG GID=1001


##add this in .env 
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
##gunicorn env
ENV PATH=$PATH:/home/$UNAME/.local/bin/
ENV DJANGO_SETTINGS_MODULE=commons.settings


RUN apt-get update -y
RUN apt-get install -y --no-install-recommends gdal-bin \
    curl \
    telnet \
    vim

# Create a user group 'xyzgroup' with id
# -g, --gid GROUP Name or ID of the primary group.
RUN groupadd -g $GID -o $UNAME

# Create a user  under the above group
#-m, --create-home Create the user's home directory.
# -g, --gid GROUP Name or ID of the primary group.
# -s, --shell SHELL Login shell of the new account.
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME
WORKDIR /home/$UNAME/code

COPY --from=builder --chown=$UNAME:$UNAME /code/wheels /wheels
COPY --from=builder --chown=$UNAME:$UNAME /code/requirements.txt .

RUN pip install --user --no-cache /wheels/*

# Adds our application code to the image
COPY --chown=$UNAME:$UNAME . /home/$UNAME/code

EXPOSE 8000

CMD ["gunicorn" ,"commons.wsgi:application", "-c","commons/config/gunicorn.py"]
