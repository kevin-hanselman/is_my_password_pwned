using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Security.Cryptography;

namespace Pwned
{
    class Program
    {
        HttpClient httpClient;
        public Program()
        {
            httpClient = new HttpClient();
            httpClient.MaxResponseContentBufferSize = System.Int32.MaxValue;

        }
        static void Main(string[] args)
        {
            Program me = new Program();
            Console.Write("Type a password to check:");
            string pswd = Console.ReadLine();
            me.Test(pswd);
            Console.Read();

        }
        public async void Test(string password)
        {
            string sha1 = Hash(password);
            string prefix = sha1.Substring(0, 5);
            string subfix = sha1.Substring(5).ToUpper();
            Console.WriteLine("Password Prefix: {0}", prefix);
            Console.WriteLine("Password Subfix: {0}", subfix);
            Console.WriteLine("Querying...");
            HttpResponseMessage x = await httpClient.GetAsync("https://api.pwnedpasswords.com/range/"+ prefix );
            string str = await x.Content.ReadAsStringAsync();
            string[] entries = str.Split(new[] { Environment.NewLine },  StringSplitOptions.None);

            for (int i = 0; i < entries.Length; i++)
            {
                if (entries[i].IndexOf(subfix) > -1)
                {
                    string[] param =  entries[i].Split(':');
                    Console.WriteLine("Your password appears in the Pwned Passwords database {0} time(s).", param[1]);
                    Alert(param[1]);
                    break;
                }
            }
        }
        static string Hash(string input)
        {
            var hash = (new SHA1Managed()).ComputeHash(Encoding.UTF8.GetBytes(input));
            return string.Join("", hash.Select(b => b.ToString("x2")).ToArray());
        }
        static void Alert(string times)
        {
            int count = Int32.Parse(times);
            if (count > 100)
            {
                Console.WriteLine("Your password is thoroughly pwned! DO NOT use this password for any reason!");
            }else if (count > 20)
            {
                Console.WriteLine("Your password is pwned! You should not use this password!");
            }else if (count > 0)
            {
                Console.WriteLine("Your password is pwned, but not ubiquitous. Use this password at your own risk!");
            }
            else
            {
                Console.WriteLine("Your password isn't pwned, but that doesn't necessarily mean it's secure!");
            }
        }
    }
}

