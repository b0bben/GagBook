/*
 * Copyright (c) 2012-2013 Dickson Leong.
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
 *     * Neither the name of GagBook nor the names of its contributors may be
 *       used to endorse or promote products derived from this software without
 *       specific prior written permission.
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

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QtCore/QObject>
#include <QtCore/QScopedPointer>

class QSettings;

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int selectedSection READ selectedSection WRITE setSelectedSection NOTIFY selectedSectionChanged)
    Q_PROPERTY(int imageSize READ imageSize WRITE setImageSize NOTIFY imageSizeChanged)
    Q_PROPERTY(bool whiteTheme READ isWhiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
    Q_PROPERTY(bool zoomSliderVisible READ isZoomSliderVisible WRITE setZoomSliderVisible
               NOTIFY zoomSliderVisibleChanged)
public:
    static Settings *instance();

    int selectedSection() const;
    void setSelectedSection(int selectedSection);

    int imageSize() const;
    void setImageSize(int imageSize);

    bool isWhiteTheme() const;
    void setWhiteTheme(bool whiteTheme);

    bool isZoomSliderVisible() const;
    void setZoomSliderVisible(bool visible);

signals:
    void selectedSectionChanged();
    void imageSizeChanged();
    void whiteThemeChanged();
    void zoomSliderVisibleChanged();

private:
    static QScopedPointer<Settings> m_instance;

    explicit Settings(QObject *parent = 0);
    Q_DISABLE_COPY(Settings)

    QSettings *m_settings;

    int m_selectedSection;
    int m_imageSize;
    bool m_whiteTheme;
    bool m_zoomSliderVisible;
};

#endif // SETTINGS_H