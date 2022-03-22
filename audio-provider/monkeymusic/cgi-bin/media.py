#!/usr/bin/python2

import cgi
import cgitb; cgitb.enable() # Optional for debugging only
import hashlib
import json
import logging
import os
import sys
import traceback

################
# GLOBALS
################
PASSWORD = 'rocks'
STATUS = {200: '200 OK', 302: '302 Found', 400: '400 Bad Request', 401: 'Not Authorized'}
TOKEN_VALUE = 'ABCDEF12345'
URL_FORMAT = 'http://localhost:8000/cgi-bin/media.py?token={token}&file=media/{file}'
USER_NAME = 'yanni'
SONG_INFO = {
    'audio-file-1.mp3': {
        'name': 'Bossa Nova Song',
        'canSkip': True,
        'type': 'mp3'
    },
    'audio-file-2.mp3': {
        'name': 'K-pop Song',
        'canSkip': True,
        'type': 'mp3'
    },
    'audio-file-3.mp3': {
        'name': 'Art Punk Song',
        'canSkip': True,
        'type': 'mp3'
    },
    'audio-file-4.mp3': {
        'name': 'Country Rap Song',
        'canSkip': True,
        'type': 'mp3'
    },
    'audio-file-5.mp3': {
        'name': 'Stay Awhile and Listen',
        'canSkip': False,
        'type': 'mp3'
    },
    'audio-file-6.m4a': {
        'name': 'Mainstream Jazz Song',
        'canSkip': True,
        'type': 'm4a'
    }
}



def generateGenericError():
    return (STATUS[400], 'text/plain', 'There was an error in your request', {})

def generateLoginForm():
    status = STATUS[200]
    contentType = 'text/html'
    body  = '<html><body>'
    body += '<p>Enter credentials for music (autofilled for convenience):</p>'
    body += '<form action="/cgi-bin/media.py" method="GET">'
    body += 'User name: <input type="text" name="user" value="' + USER_NAME + '"/><br/>'
    body += 'Password: <input type="password" name="password" value="' + PASSWORD + '"/><br/>'
    body += '<input type="hidden" name="redirectUrl" value="' + redirectUrl + '"/>'
    body += '<input type="submit" value="Log In"/></form>'
    body += '</body></html>'
    return (status, contentType, body, {})

def listFiles(token):
    if token == TOKEN_VALUE:
        fileMapping = {}
        for file, meta in SONG_INFO.viewitems():
            fileMapping[file] = {
                'url': URL_FORMAT.format(token=token, file=file),
                'id': hashlib.md5(file).hexdigest(),
                'name': meta['name'],
                'canSkip': meta['canSkip'],
                'type': meta['type']
            }
        return (STATUS[200], 'application/json', json.dumps(fileMapping), {})
    else:
        error = {'errorMessage': 'Invalid token'}
        return (STATUS[401], 'application/json', json.dumps(error), {})

def serveFile(token, requestedFile):
    logging.debug('servFile' + ' token=' + token + ' requestedFile=' + requestedFile)
    if token == TOKEN_VALUE:
        try:
            with open(requestedFile, "rb") as f:
                body = f.read()
        except IOError, e:
            error = {'errorMessage': 'Unknown song'}
            logging.debug(json.dumps(error))
            return (STATUS[400], 'application/json', json.dumps(error), {})

        otherHeaders = {}
        otherHeaders['Content-Length'] = str(os.path.getsize(requestedFile))
        otherHeaders['Accept-Ranges'] = 'bytes'
        otherHeaders['Content-Disposition'] = '"attachment; filename=' + requestedFile + '"'

        if requestedFile.endswith('mp3'):
            contentType = 'audio/mpeg'
        elif requestedFile.endswith('mp4'):
            contentType = 'audio/mp4'
        elif requestedFile.endswith('m4a'):
            contentType = 'audio/aac'
        else:
            return (STATUS[400], 'text/plain', 'unknown content type', {})

        return (STATUS[200], contentType, body, otherHeaders)
    else:
        return (STATUS[401], 'text/plain', 'bad token', {})

def verifyUserAndRedirect(user, password):
    otherHeaders = {}
    if user == USER_NAME and password == PASSWORD:
        status = STATUS[302]
        contentType = 'text/plain'
        body = 'redirecting'
        otherHeaders['Location'] = redirectUrl + '?token=' + TOKEN_VALUE
    else:
        contentType = 'text/plain'
        status = STATUS[401]
        body = 'redirecting'
        otherHeaders['Location'] = redirectUrl + '?errorMessage=Invalid%20credentials'

    return (status, contentType, body, otherHeaders)

################
# MAIN
################
logging.basicConfig(filename='media.log', level=logging.DEBUG)

try:
    params = cgi.FieldStorage()

    if params.has_key('redirectUrl'):
        redirectUrl = params['redirectUrl'].value
        user = params['user'].value if 'user' in params else None
        password = params['password'].value if 'password' in params else None
        if not params.has_key('user'):
            (status, contentType, body, otherHeaders) = generateLoginForm()
        else:
            (status, contentType, body, otherHeaders) = verifyUserAndRedirect(user, password)
    elif params.has_key('file'):
        logging.debug('getting file')
        token = params['token'].value
        requestedFile = params['file'].value
        (status, contentType, body, otherHeaders) = serveFile(token, requestedFile)
    elif params.has_key('mode'):
        mode = params['mode'].value
        if mode == 'listing':
            token = params['token'].value
            (status, contentType, body, otherHeaders) = listFiles(token)
        else:
            (status, contentType, body, otherHeaders) = generateGenericError()
    else:
        (status, contentType, body, otherHeaders) = generateGenericError()

    # output page
    print 'Status: ' + status
    print 'Content-Type: ' + contentType
    for key in otherHeaders:
        print key + ': ' + otherHeaders[key]
    print
    print body
except:
    print 'Content-Type: text/html'
    print
    print "\n\n<PRE>"
    traceback.print_exc()
