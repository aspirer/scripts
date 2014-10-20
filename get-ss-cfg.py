#! /usr/bin/python

import HTMLParser  

import requests


class MyHTMLParser(HTMLParser.HTMLParser):
    code_tag = False
    count = 1
    def handle_starttag(self, tag, attr):
        if tag == 'code':
            self.code_tag = True

    def handle_endtag(self, tag):
        if tag == 'code':
            self.code_tag = False

    def handle_data(self, data):
        if self.code_tag and 'server' in data:
            print data
            file_name = 'ss-' + str(self.count) + '.cfg'
            with open(file_name, 'w') as f:
                f.write(data.strip())
            self.count += 1


if __name__ == '__main__':
    resp = requests.get('http://boafanx.tabboa.com/boafanx-ss/')

    myhp = MyHTMLParser()
    myhp.feed(resp.content)
    myhp.close()
