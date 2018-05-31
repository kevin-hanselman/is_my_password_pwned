using System;
using System.Net.Http;
using Windows.Security.Cryptography;
using Windows.Security.Cryptography.Core;
using Windows.Storage.Streams;

namespace checkpswd
{
    class Bin
    {
        HttpClient httpClient;
        public Bin()
        {
            httpClient = new HttpClient();
            httpClient.MaxResponseContentBufferSize = System.Int32.MaxValue;
        }
        public delegate void Callback(string s, string arg);
        public async void Test(string password, Callback t)
        {
            string sha1 = Hash(password);
            string prefix = sha1.Substring(0, 5);
            string subfix = sha1.Substring(5).ToUpper();
            t("Password Prefix: {0}", prefix);
            t("Password Subfix: {0}", subfix);
            HttpResponseMessage x = await httpClient.GetAsync("https://api.pwnedpasswords.com/range/" + prefix);
            string str = await x.Content.ReadAsStringAsync();
            string[] entries = str.Split(new[] { Environment.NewLine }, StringSplitOptions.None);

            bool found_match = false;
            for (int i = 0; i < entries.Length; i++)
            {
                if (entries[i].IndexOf(subfix) > -1)
                {
                    found_match = true;
                    string[] param = entries[i].Split(':');
                    t("Your password appears in the Pwned Passwords database {0} time(s).", param[1]);
                    Alert(param[1], t);

                    break;
                }
            }
            if (!found_match)
            {
                t("Your password isn't pwned, but that doesn't necessarily mean it's secure!", "");
                t("[DONE]", "");
            }

        }
        static string Hash(string input)
        {
            var hash = ComputeSHA1(input);
            return hash;
        }

        private static string ComputeSHA1(string str)
        {
            var alg = HashAlgorithmProvider.OpenAlgorithm(HashAlgorithmNames.Sha1);
            IBuffer buff = CryptographicBuffer.ConvertStringToBinary(str, BinaryStringEncoding.Utf8);
            var hashed = alg.HashData(buff);
            var res = CryptographicBuffer.EncodeToHexString(hashed);
            return res;
        }
        static void Alert(string times, Callback t)
        {
            int count = Int32.Parse(times);
            if (count > 100)
            {
                t("Your password is thoroughly pwned! DO NOT use this password for any reason!", "");
            }
            else if (count > 20)
            {
                t("Your password is pwned! You should not use this password!", "");
            }
            else if (count > 0)
            {
                t("Your password is pwned, but not ubiquitous. Use this password at your own risk!", "");
            }
            else
            {
                t("Your password isn't pwned, but that doesn't necessarily mean it's secure!", "");
            }
            t("[DONE]", "");
        }
    }
}
