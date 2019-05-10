// Copyright (c) 2009-2017 The Bitcoin Core developers
// Copyright (c) 2017-2018 The COMMACOIN developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BITCOIN_CMCENTVERSION_H
#define BITCOIN_CMCENTVERSION_H

#if defined(HAVE_CONFIG_H)
#include "config/commacoin-config.h"
#endif //HAVE_CONFIG_H

// Check that required client information is defined
#if !defined(CMCENT_VERSION_MAJOR) || !defined(CMCENT_VERSION_MINOR) || !defined(CMCENT_VERSION_REVISION) || !defined(CMCENT_VERSION_BUILD) || !defined(CMCENT_VERSION_IS_RELEASE) || !defined(COPYRIGHT_YEAR)
#error Client version information missing: version is not defined by commacoin-config.h or in any other way
#endif

/**
 * Converts the parameter X to a string after macro replacement on X has been performed.
 * Don't merge these into one macro!
 */
#define STRINGIZE(X) DO_STRINGIZE(X)
#define DO_STRINGIZE(X) #X

//! Copyright string used in Windows .rc files
#define COPYRIGHT_STR "2009-" STRINGIZE(COPYRIGHT_YEAR) " The Bitcoin Core Developers, 2014-" STRINGIZE(COPYRIGHT_YEAR) " The Dash Core Developers, 2015-" STRINGIZE(COPYRIGHT_YEAR) " The COMMACOIN Core Developers"

/**
 * commacoind-res.rc includes this file, but it cannot cope with real c++ code.
 * WINDRES_PREPROC is defined to indicate that its pre-processor is running.
 * Anything other than a define should be guarded below.
 */

#if !defined(WINDRES_PREPROC)

#include <string>
#include <vector>

static const int CMCENT_VERSION =
    1000000 * CMCENT_VERSION_MAJOR  ///
    + 10000 * CMCENT_VERSION_MINOR  ///
    + 100 * CMCENT_VERSION_REVISION ///
    + 1 * CMCENT_VERSION_BUILD;

extern const std::string CMCENT_NAME;
extern const std::string CMCENT_BUILD;
extern const std::string CMCENT_DATE;


std::string FormatFullVersion();
std::string FormatSubVersion(const std::string& name, int nClientVersion, const std::vector<std::string>& comments);

#endif // WINDRES_PREPROC

#endif // BITCOIN_CMCENTVERSION_H
