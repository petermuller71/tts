#  trustedtimestamping - R package for creating Trusted Timestamps (tts)
#  Trusted Timestamps (tts) are created by submitting a sha256 hash of the file or dataset into a transaction on the decentralized blockchain (Stellar network).
#  The package makes use of a free service provided by https://stellarapi.io.
#
#  Copyright (C) 2019-present, Peter A. Muller
#
#  This file is part of the trustedtimestamping R package.
#
#  The trustedtimestamping R package is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Affero General Public License version 3 as
#  published by the Free Software Foundation.
#
#  The trustedtimestamping R package is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
#  for more details.
#
#  You should have received a copy of the GNU Affero General Public License along
#  with the trustedtimestamping R package. If not, see <http://www.gnu.org/licenses/>.
#
#  You can contact the author at:
#  - trustedtimestamping R package source repository : https://github.com/ttspackage/tts



#' @importFrom httr GET content
#' @export
httr::GET
httr::content

#' @importFrom digest digest
#' @export
digest::digest

#' @importFrom jsonlite fromJSON base64_dec
#' @export
jsonlite::fromJSON


#' Create trusted timestamp of an object/dataset
#'
#' @param data any dataset or object
#'
#' @return url
#' @export
#'
#' @examples
#' create_ttsObject(data)
create_ttsObject <- function(data) {

  hash <- digest(data, algo=c("sha256"))

  url  <- paste("https://stellarapi.io/storehash/", hash)
  url  <- gsub(" ", "", url, fixed = TRUE)

  req  <- GET(url)
  json <- content(req, "text")
  res  <- fromJSON(json)

  url  <- paste("https://stellarapi.io/gethash/",res['transactionid'])
  url  <- gsub(" ", "", url, fixed = TRUE)

  return(url)

}

#' Create trusted timestamp of a file
#'
#' @param path filename (and path, if outside working directory)
#'
#' @return url
#' @export
#'
#' @examples
#' create_ttsFile("test.rds")
create_ttsFile <- function(path) {

  if (!is.character(path)) stop("Please specify a correct path.")

  if (!file.exists(path)) {
    print(c('File: ',path,' not found.'))
  }
  else {

    hash <- digest(path, algo="sha256", file=TRUE)

    url  <- paste("https://stellarapi.io/storehash/", hash)
    url  <- gsub(" ", "", url, fixed = TRUE)

    req  <- GET(url)
    json <- content(req, "text")
    res  <- fromJSON(json)

    url  <- paste("https://stellarapi.io/gethash/",res['transactionid'])
    url  <- gsub(" ", "", url, fixed = TRUE)

    return(url)
  }
}

#' Create hash of an object/dataset
#'
#' @param data any dataset or object
#'
#' @return hash
#' @export
#'
#' @examples
#' create_hashObject(data)
create_hashObject <- function(data) {

  hash <- digest(data, algo=c("sha256"))
  return(hash)

}


#' Create hash of a file
#'
#' @param path filename (and path, if outside working directory) of a file
#'
#' @return hash
#' @export
#'
#' @examples
#' create_hashFile("test.rds")
create_hashFile <- function(path) {

  if (!is.character(path)) stop("Please specify a correct path.")

  if (!file.exists(path)) {
    print(c('File: ',path,' not found.'))
  }
  else {

    hash <- digest(path, algo="sha256", file=TRUE)
    return(hash)
  }

}


#' Retrieve hash from STELLAR network
#'
#' @param url url
#'
#' @return hash
#' @export
#'
#' @examples
#' get_hash("https://stellarapi.io/gethash/ea0ae0")
get_hash <- function(url) {

  req  <- GET(url)
  json <- content(req, "text")
  res  <- fromJSON(json)
  hex  <- unlist(res['memo-hexformat'], recursive = F, use.names = F)
  return(hex)

}

#' Retrieve timestamp from STELLAR network
#'
#' @param url url
#'
#' @return GMT GMT-timestamp
#' @export
#'
#' @examples
#' get_timestamp("https://stellarapi.io/gethash/ea0ae0")
get_timestamp <- function(url) {

  req  <- GET(url)
  json <- content(req, "text")
  res  <- fromJSON(json)
  GMT  <- unlist(res['GMT-timestamp'], recursive = F, use.names = F)
  return(GMT)

}

#' Retrieve url of the transaction on STELLAR network
#'
#' @param url url
#'
#' @return url url of blockchain transaction
#' @export
#'
#' @examples
#' get_url_blockchaintransaction("https://stellarapi.io/gethash/ea0ae0")
get_url_blockchaintransaction <- function(url) {

  req  <- GET(url)
  json <- content(req, "text")
  res  <- fromJSON(json)
  url  <-  unlist(res['stellar-link'], recursive = F, use.names = F)
  return(url)

}


#' Validate hash of object/dataset (created on the fly) with hash on STELLAR network
#'
#' @param url url
#' @param data any dataset or object
#'
#' @return res result of validation
#' @export
#'
#' @examples
#' validate_hashObject("https://stellarapi.io/gethash/ea0ae0", data)
validate_hashObject <- function(url, data) {

  req          <- GET(url)
  json         <- content(req, "text")
  res          <- fromJSON(json)
  hashonthefly <- digest(data, algo=c("sha256"))
  hash         <- res['memo-hexformat']

  if(hashonthefly == hash){
    res <- "correct"
  }
  else {
    res <- "not correct"
  }

  return(res)
}


#' Validate hash of a file (created on the fly) with hash on STELLAR network
#'
#' @param url url
#' @param path filename (and path, if outside working directory)
#'
#' @return res result of validation
#' @export
#'
#' @examples
#' validate_hashFile("https://stellarapi.io/gethash/ea0ae0", "test.rds")
validate_hashFile <- function(url, path) {

  if (!is.character(path)) stop("Please specify a correct path.")

  if (!file.exists(path)) {
    print(c('File: ',path,' not found.'))
  }
  else {

    req          <- GET(url)
    json         <- content(req, "text")
    res          <- fromJSON(json)
    hashonthefly <- digest(path, algo="sha256", file=TRUE)
    hash         <- res['memo-hexformat']

    if(hashonthefly == hash){
      res <- "correct"
    }
    else {
      res <- "not correct"
    }

    return(res)

  }
}



#' Convert hash on STELLAR network (base64 encoded) to standard hexadecimal value
#'
#' @param data base64 encoded hash
#'
#' @return hex hexadecimal hash
#' @export
#'
#' @examples
#' convert_stellarHash("KMVvhSYRAquk3lPpzljU4SytQSawsTz1aeB+PoKFaf0=")
convert_stellarHash <- function(data) {

  dec <- base64_dec(data)
  hex <- paste( unlist(dec), collapse='')

  return(hex)

}
