/*
 * Copyright (c) 2014 Dickson Leong.
 * All rights reserved.
 *
 * This file is part of GagBook.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "ninegagrequest.h"

#include <QtCore/QRegExp>
#include <QUrl>
#include <QUrlQuery>
#include <QtXml>
#include <QTextDocument>
#include <QXmlQuery>

#include "networkmanager.h"

NineGagRequest::NineGagRequest(NetworkManager *networkManager, const QString &section, QObject *parent) :
    GagRequest(networkManager, section, parent)
{
}

QNetworkReply *NineGagRequest::createRequest(const QString &section, const QString &lastId)
{
    QUrl requestUrl("http://9gag.com/" + section);
    QUrlQuery q;
    if (!lastId.isEmpty()) {
        q.addQueryItem("id", lastId);
        requestUrl.setQuery(q);
    }

    return networkManager()->createGetRequest(requestUrl, NetworkManager::JSON);
}

static QList<GagObject> getEntryItemsFromHtml(const QString &html);
static QList<GagObject> getEntryItemsFromJson(const QString &json);
static GagObject parseGag(QXmlStreamReader &xml);

QList<GagObject> NineGagRequest::parseResponse(const QByteArray &response)
{
    qDebug("parsing response...");
    return getEntryItemsFromJson(QString::fromUtf8(response));
}

// can not use Qt-Json to parse this JSON because it will cause the order
// of entry-item to be sorted when parsed into a QVariantMap
static QList<GagObject> getEntryItemsFromJson(const QString &json)
{
    QBuffer device;
    device.setData(json.toUtf8());
    device.open(QIODevice::ReadOnly);

    QXmlQuery query;
    query.bindVariable("inputDocument", &device);
    query.setQuery("doc($inputDocument)/article");

    QString r;
    query.evaluateTo(&r);

    qDebug() << r;

    QList<GagObject> gags;
    return gags;
    //return getEntryItemsFromHtml(html);
}

static QList<GagObject> getEntryItemsFromHtml(const QString &html)
{
    QList<GagObject> gags;

    QXmlStreamReader xml(html);
    xml.setNamespaceProcessing(false);
    /* We'll parse the XML until we reach end of it.*/
    while(!xml.atEnd() &&
          !xml.hasError()) {
        /* Read next element.*/
        QXmlStreamReader::TokenType token = xml.readNext();
        qDebug("readNext");
        /* If token is just StartDocument, we'll go to next.*/
        if(token == QXmlStreamReader::Invalid || token == QXmlStreamReader::StartDocument) {
            continue;
        }
        /* If token is StartElement, we'll see if we can read it.*/
        if(token == QXmlStreamReader::StartElement) {
            /* If it's an article, we'll dig the information from there.*/
            if(xml.name() == "article") {
                qDebug("found article, parsing...");
                gags.append(parseGag(xml));
            }
        }
        else
            continue;
    }
    /* Error handling. */
    if(xml.hasError()) {
        qDebug() << xml.errorString();
    }
    /* Removes any device() or data from the reader
        * and resets its internal state to the initial state. */
    xml.clear();

    return gags;
}

static GagObject parseGag(QXmlStreamReader& xml) {
    GagObject gag;
    /* Let's check that we're really getting a person. */
    if(xml.tokenType() != QXmlStreamReader::StartElement &&
            xml.name() == "article") {
        return gag;
    }
    /* Let's get the attributes for person */
    QXmlStreamAttributes attributes = xml.attributes();
    /* Let's check that person has id attribute. */
    if(attributes.hasAttribute("data-entry-id")) {
        /* We'll add it to the map. */
        gag.setId(attributes.value("data-entry-id").toString());
    }

    if(attributes.hasAttribute("data-entry-url")) {
        /* We'll add it to the map. */
        gag.setUrl(attributes.value("data-entry-url").toString());
    }

    if(attributes.hasAttribute("data-entry-votes")) {
        /* We'll add it to the map. */
        qDebug() << "votes: " << attributes.value("data-entry-votes").toInt();
        gag.setVotesCount(attributes.value("data-entry-votes").toInt());
    }

    if(attributes.hasAttribute("data-entry-comments")) {
        /* We'll add it to the map. */
        qDebug() << "comments: " << attributes.value("data-entry-comments").toInt();
        gag.setCommentsCount(attributes.value("data-entry-comments").toInt());
    }

    /* Next element... */
    xml.readNext();
    /*
     * We're going to loop over the things because the order might change.
     * We'll continue the loop until we hit an EndElement named person.
     */
    while(!(xml.tokenType() == QXmlStreamReader::EndElement &&
            xml.name() == "article")) {
        if(xml.tokenType() == QXmlStreamReader::StartElement) {
            /* We've found title. */
            if(xml.name() == "a") {
                qDebug() << "title: " << xml.text().toString();
                gag.setTitle(xml.text().toString());
            }
            /* We've found image. */
            if(xml.name() == "img") {
                if(attributes.hasAttribute("class") && attributes.value("class").toString() == "badge-item-img") {
                    qDebug() << "img url: " << xml.text().toString();
                    gag.setImageUrl(attributes.value("src").toString());
                }
            }
        }
        /* ...and next... */
        xml.readNext();
    }

    qDebug("parseGag END");
    return gag;
}

static const QRegExp dataScriptImgSrcRegExp("<img.*src=\"(http[^\\s\"]+)\".*\\/>");
