﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TutteeFrame2.Model
{
    class Punishment : ResultObject
    {
        private string fault;
        public Punishment()
        {

        }
        public Punishment(string _studentID)
        {

            Random random = new Random();
            iD = _studentID + (random.Next(1000, 9999)).ToString();
        }
        public string Fault { get => fault; set => fault = value; }
    }
}
