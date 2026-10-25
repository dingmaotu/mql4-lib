//+------------------------------------------------------------------+
//| mungeEmail.mqh                                                   |
//|                                                                  |
//| Utility functions for masking personally identifiable            |
//| information (PII).                                               |
//|                                                                  |
//| Currently provides functionality for obfuscating email           |
//| addresses before logging, displaying or exporting data.          |
//|                                                                  |
//| Author : Lawrence Reid                                           |
//| Library: mql-lib                                                 |
//+------------------------------------------------------------------+

#property strict

//+------------------------------------------------------------------+
//| Obfuscates an email address.                                     |
//|                                                                  |
//| The method preserves the beginning and end of the address while  |
//| replacing the majority of the local portion with asterisks.      |
//|                                                                  |
//| Example                                                         |
//|   john.smith@example.com                                         |
//|   => jo********@example.com                                      |
//|                                                                  |
//| Parameters                                                       |
//|   email - Email address to be obfuscated.                        |
//|                                                                  |
//| Returns                                                          |
//|   The obfuscated email address.                                  |
//|                                                                  |
//| Notes                                                            |
//|   - If the string does not contain an '@' character, the        |
//|     original string is returned unchanged.                       |
//|   - Intended for logging and display purposes only.              |
//+------------------------------------------------------------------+
string MungeEmailAddress(const string email)
{
   const int atIndex = StringFind(email, "@");

   if(atIndex < 0)
      return email;

   const int startIndex = (int)(atIndex * 0.20);
   const int endIndex   = (int)(atIndex * 0.90);

   string result =
      (startIndex > 0)
      ? StringSubstr(email, 0, startIndex)
      : "";

   for(int i = startIndex; i <= endIndex; i++)
      result += "*";

   result += StringSubstr(email, endIndex + 1);

   return result;
}
//+------------------------------------------------------------------+
// Preserve the original entrypoint used by existing STS callers.
string mungeEmailAddress(const string email)
{
   return MungeEmailAddress(email);
}
//+------------------------------------------------------------------+
