__author__ = 'matelau'
import urllib
# get list of universities
f = open("UNIS.TXT", "r").read().replace("'", "").splitlines()
url = "http://www.american-school-search.com/images/logo/"
urllist = {}
# build urls for each university
for uni in f:
    curr_uni = uni
    if "-" in uni:
        curr_uni = uni.split("-")[0]
    if "." in curr_uni:
        curr_uni = curr_uni.replace(".", "")
    curr_uni = curr_uni.replace(" ", "-").lower()
    curr_url = url+curr_uni+".gif"
    urllist[curr_uni] = curr_url

# Retrieve pictures
for uni in urllist.keys():
    logo_url = urllist[uni]
    urllib.urlretrieve(logo_url, uni+".gif")
