//+------------------------------------------------------------------+
//| Module: Format/Resp.mqh                                          |
//| This file is part of the mql4-lib project:                       |
//|     https://github.com/dingmaotu/mql4-lib                        |
//|                                                                  |
//| Copyright 2017 Li Ding <dingmaotu@126.com>                       |
//|                                                                  |
//| Licensed under the Apache License, Version 2.0 (the "License");  |
//| you may not use this file except in compliance with the License. |
//| You may obtain a copy of the License at                          |
//|                                                                  |
//|     http://www.apache.org/licenses/LICENSE-2.0                   |
//|                                                                  |
//| Unless required by applicable law or agreed to in writing,       |
//| software distributed under the License is distributed on an      |
//| "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,     |
//| either express or implied.                                       |
//| See the License for the specific language governing permissions  |
//| and limitations under the License.                               |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| This is an implementation of the RESP serilization protocol used |
//| in Redis. Following is from official protocol description:       |
//|                                                                  |
//| The RESP protocol was introduced in Redis 1.2, but it became the |
//| standard way for talking with the Redis server in Redis 2.0. This|
//| is the protocol you should implement in your Redis client.       |
//|                                                                  |
//| RESP is actually a serialization protocol that supports the      |
//| following data types: Simple Strings, Errors, Integers,          |
//| Bulk Strings and Arrays.                                         |
//|                                                                  |
//| The way RESP is used in Redis as a request-response protocol is  |
//| the following:                                                   |
//| Clients send commands to a Redis server as a RESP Array of       |
//| Bulk Strings.                                                    |
//| The server replies with one of the RESP types according to the   |
//| command implementation.                                          |
//|                                                                  |
//| In RESP, the type of some data depends on the first byte:        |
//| For Simple Strings the first byte of the reply is "+"            |
//| For Errors the first byte of the reply is "-"                    |
//| For Integers the first byte of the reply is ":"                  |
//| For Bulk Strings the first byte of the reply is "$"              |
//| For Arrays the first byte of the reply is "*"                    |
//|                                                                  |
//| Additionally RESP is able to represent a Null value using a      |
//| special variation of Bulk Strings or Array as specified later.   |
//| In RESP different parts of the protocol are always terminated    |
//| with "\r\n" (CRLF).                                              |
//+------------------------------------------------------------------+
#include "RespValue.mqh"
#include "RespBytes.mqh"
#include "RespArray.mqh"
#include "RespInteger.mqh"
#include "RespString.mqh"
#include "RespMsgParser.mqh"
#include "RespStreamParser.mqh"
//+------------------------------------------------------------------+
