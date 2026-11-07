using System;
using System.IO;
using UnityEngine;
using TravelVietnamese.Domain;
namespace TravelVietnamese.UnityPrototype
{
    public static class PassJournal
    {
        static string PathName {get{return Path.Combine(Application.persistentDataPath,"unity-pass-v1.json");}}
        public static JourneyState Load(out string error)
        {
            error="";
            if(!File.Exists(PathName))return new JourneyState();
            try{JourneyState loaded=JsonUtility.FromJson<JourneyState>(File.ReadAllText(PathName));if(loaded==null || loaded.Version!=1)throw new InvalidDataException("Unsupported save version");return PassRules.Normalize(loaded); }
            catch(Exception ex){error="Không đọc được bản lưu. Tệp cũ được giữ đến khi bạn chọn Lưu. "+ex.GetType().Name;return new JourneyState();}
        }
        public static bool Save(JourneyState state,out string error)
        {
            error="";string temp=PathName+".tmp";
            try
            {
                Directory.CreateDirectory(Application.persistentDataPath);
                using(FileStream stream=new FileStream(temp,FileMode.Create,FileAccess.Write,FileShare.None))
                using(StreamWriter writer=new StreamWriter(stream)){writer.Write(JsonUtility.ToJson(PassRules.Normalize(state)));writer.Flush();stream.Flush(true);}
                if(File.Exists(PathName))File.Replace(temp,PathName,PathName+".bak");else File.Move(temp,PathName);
                return true;
            }
            catch(Exception ex){error="Chưa lưu được; thử Lưu trước khi thoát. "+ex.GetType().Name;return false;}
        }
    }
}
