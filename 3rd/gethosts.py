# !/usr/bin/python
# -*- encoding: utf-8 -*-

#################################################################
# BRIEF:    Crawler for Hosts File (Python 2.7 required)
# SITE:     https://github.com/racaljk/hosts/blob/master/hosts
# AUTHOR:   gaochao.morgen@gmail.com
# V1.0      2017-04-28  Create
#################################################################

import sys
import cookielib
import urllib
import urllib2

from lxml import html


##################################################
#                   Functions                    #
##################################################


def set_auto_cookie():
    """
    Setup a cookie handler. It will help us handle cookie automatically.
    :return:
    """

    global GCJ
    GCJ = cookielib.LWPCookieJar()
    cookie_support = urllib2.HTTPCookieProcessor(GCJ)
    opener = urllib2.build_opener(cookie_support, urllib2.HTTPHandler)
    urllib2.install_opener(opener)


def require_page_with_http(url, body=None, headers=None):
    """
    Require web page using HTTP, and return the page content.
    :param url: Full path URL
    :param body: POST data(if necessary)
    :param headers: More headers(if necessary)
    :return: Page Content
    """

    post = (None if body is None else urllib.urlencode(body))
    request = urllib2.Request(url, post)

    http_headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 5.1; rv:45.0) Gecko/20100101 Firefox/45.0'}
    if headers is not None:
        http_headers.update(headers)

    for key in http_headers:
        request.add_header(key, http_headers[key])

    try:
        response = urllib2.urlopen(request)
        content = response.read()
        if len(content) > 0:
            return content
    except urllib2.HTTPError, e:
        print "The server couldn't fulfill the request."
        print "Error code: ", e.code
    except urllib2.URLError, e:
        print "We failed to reach a server."
        print "Reason: ", e.reason
    except:
        print "Unknown Exception."

    return None


##################################################
#                   Application                  #
##################################################

if __name__ == "__main__":
    set_auto_cookie()

    #page = require_page_with_http('https://github.com/racaljk/hosts/blob/master/hosts')
    page = require_page_with_http('https://github.com/googlehosts/hosts/blob/master/hosts-files/hosts')

    # Now we get the web page
    tree = html.fromstring(page)
    if tree is None:
        sys.exit(-1)

    # Parse the web page using XPath
    shops = tree.xpath("//td[@class='blob-code blob-code-inner js-file-line']")
    try:
        f = file('../log/hosts.parsed', 'w')
        for shop in shops:
            f.write(shop.text + '\n')
        f.close()
    except:
        print 'Parse Error.'
        sys.exit(-1)

    sys.exit(0)

