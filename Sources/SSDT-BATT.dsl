DefinitionBlock ("", "SSDT", 2, "LENOVO", "BATT", 0x00000000)
{
    External (_SB.PCI0.LPCB, DeviceObj)
    External (_SB.PCI0.LPCB.EC0, DeviceObj)

    Method (B1B2, 2, NotSerialized)
    {
        Return ((Arg0 | (Arg1 << 0x08)))
    }

    Method (B1B4, 4, NotSerialized)
    {
        Local0 = (Arg2 | (Arg3 << 0x08))
        Local0 = (Arg1 | (Local0 << 0x08))
        Local0 = (Arg0 | (Local0 << 0x08))
        Return (Local0)
    }

    Method (W16B, 3, NotSerialized)
    {
        Arg0 = Arg2
        Arg1 = (Arg2 >> 0x08)
    }

    Scope (_SB.PCI0.LPCB.EC0)
    {
        Method (RE1B, 1, NotSerialized)
        {
            OperationRegion (ERM2, EmbeddedControl, Arg0, One)
            Field (ERM2, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            Return (BYTE) /* \RE1B.BYTE */
        }

        Method (RECB, 2, Serialized)
        {
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            Name (TEMP, Buffer (Arg1){})
            Arg1 += Arg0
            Local0 = Zero
            While ((Arg0 < Arg1))
            {
                TEMP [Local0] = RE1B (Arg0)
                Arg0++
                Local0++
            }

            Return (TEMP) /* \RECB.TEMP */
        }

        Method (WE1B, 2, NotSerialized)
        {
            OperationRegion (ERM2, EmbeddedControl, Arg0, One)
            Field (ERM2, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8
            }

            BYTE = Arg1
        }

        Method (WECB, 3, Serialized)
        {
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            Name (TEMP, Buffer (Arg1){})
            TEMP = Arg2
            Arg1 += Arg0
            Local0 = Zero
            While ((Arg0 < Arg1))
            {
                WE1B (Arg0, DerefOf (TEMP [Local0]))
                Arg0++
                Local0++
            }
        }
     }

    //The modified scope of EC
    Scope (_SB.PCI0.LPCB)
    {
        Device (EC0)
        {
            Name (ECAV, Zero)
            Mutex (LFCM, 0x00)
            //Name (_HID, EisaId ("PNP0C09")
            // ERAM to ERAN
            OperationRegion (ERAN, EmbeddedControl, Zero, 0xFF)
            Field (ERAN, ByteAcc, Lock, Preserve)
            {
               B1TY,   1, 
               B1ST,   8, 
               SMPR,   8, 
               SMST,   8, 
               SMAD,   8, 
               SMCM,   8, 
               BCNT,   8, 
               FUSL,   8, 
               FUSH,   8, 
               ECON,   8, 
               B1CT,   8, 
               B1AT,   8, 
               //FWBT,   64,  //0x14 MHIF,GSBI,GBID
               BFU0,8,BFU1,8, //BFUD
               SMDA,   256,   //0x64 MHPF(FB4)
               //BMN0,   72,  //0x8F _BIF,GSBI
               //BDN0,   64,  //0x98 _BIF,GSBI
               B1RX,8,B1RY,8, //B1RC _BST,SMTF,SMTE,GSBI
               B1SX,8,B1SY,8, //B1SN _BIF
               B1F0,8,B1F1,8, //B1FV _BST,SMTF,SMTE,GSBI
               B1D0,8,B1D1,8, //B1DV _BIF,GSBI
               B1DX,8,B1DY,8, //B1DC _BIF,GSBI
               B1FX,8,B1FY,8, //B1FC _BIF,SMTF,SMTE,GSBI
               B1A0,8,B1A1,8, //B1AC _BST,SMTF,SMTE,GSBI
               B1DI,8,B1DJ,8, //B1DA GSBI
            }
            Method (WOBE, 0, Serialized)
            {
                Local0 = 0x00010000
                While (Local0)
                {
                    Local1 = EC6C /* \_SB_.PCI0.LPCB.EC0_.EC6C */
                    If (((Local1 & One) == One))
                    {
                        Local2 = EC68 /* \_SB_.PCI0.LPCB.EC0_.EC68 */
                    }
                    Else
                    {
                        Return (Zero)
                    }

                    Stall (0x0A)
                    Local0--
                }

                Return (One)
            }
            Method (WOBF, 0, Serialized)
            {
                Local0 = 0x00010000
                While (Local0)
                {
                    Local1 = EC6C /* \_SB_.PCI0.LPCB.EC0_.EC6C */
                    If (((Local1 & One) == One))
                    {
                        Return (Zero)
                    }

                    Stall (0x0A)
                    Local0--
                }

                Return (One)
            }
            OperationRegion (CMDE, SystemIO, 0x68, 0x05)
            Field (CMDE, ByteAcc, Lock, Preserve)
            {
                EC68,   8, 
                Offset (0x02), 
                Offset (0x03), 
                Offset (0x04), 
                EC6C,   8
            }
            
            Method (WIBE, 0, Serialized)
            {
                Local0 = 0x00010000
                While (Local0)
                {
                    Local1 = EC6C /* \_SB_.PCI0.LPCB.EC0_.EC6C */
                    If (((Local1 & 0x02) == Zero))
                    {
                        Return (Zero)
                    }

                    Stall (0x0A)
                    Local0--
                }

                Return (One)
            }
            
            Method (LRAM, 2, Serialized)
            {
                If ((WIBE () == One))
                {
                    Return (One)
                }

                If ((WOBE () == One))
                {
                    Return (One)
                }

                EC6C = 0x7E
                If ((WIBE () == One))
                {
                    Return (One)
                }

                EC68 = Arg0
                If ((WIBE () == One))
                {
                    Return (One)
                }

                EC68 = Arg1
                If ((WIBE () == One))
                {
                    Return (One)
                }

                If ((WOBF () == One))
                {
                    Return (One)
                }

                Return (EC68) /* \_SB_.PCI0.LPCB.EC0_.EC68 */
            }
            
            Device (BAT0)
            {
                Name (PBIF, Package (0x0D)
                {
                    Zero, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF, 
                    One, 
                    0xFFFFFFFF, 
                    Zero, 
                    Zero, 
                    0x64, 
                    Zero, 
                    "LCFC", 
                    "BAT20101001", 
                    "LiP", 
                    "LENOVO"
                })
                Name (PBST, Package (0x04)
                {
                    One, 
                    0x0A90, 
                    0x1000, 
                    0x2A30
                })
                Name (OBST, Zero)
                Name (OBAC, Zero)
                Name (OBPR, Zero)
                Name (OBRC, Zero)
                Name (OBPV, Zero)
                Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
                {
                    If ((ECAV == One))
                    {
                        If ((Acquire (LFCM, 0xA000) == Zero))
                        {
                            Local0 = B1B2(B1DX,B1DY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1DX,B1DY) */
                            Local0 *= 0x0A
                            PBIF [One] = Local0
                            Local0 = B1B2(B1F0,B1F1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                            Local0 *= 0x0A
                            PBIF [0x02] = Local0
                            PBIF [0x04] = B1B2(B1D0,B1D1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1D0,B1D1) */
                            If (B1B2(B1F0,B1F1))
                            {
                                PBIF [0x05] = ((B1B2(B1F0,B1F1) * 0x0A) / 0x0A)
                                PBIF [0x06] = ((B1B2(B1F0,B1F1) * 0x0A) / 0x19)
                                PBIF [0x07] = ((B1B2(B1DX,B1DY) * 0x0A) / 0x64)
                            }

                            PBIF [0x09] = ""
                            PBIF [0x0A] = ""
                            PBIF [0x0B] = ""
                            PBIF [0x0C] = ""
                            Name (BDNT, Buffer (0x09)
                            {
                                 0x00                                             // .
                            })
                            BDNT = RECB(0x98,64) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x98,64) */
                            PBIF [0x09] = ToString (BDNT, Ones)
                            Local0 = B1B2(B1SX,B1SY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1SX,B1SY) */
                            Name (SERN, Buffer (0x06)
                            {
                                "     "
                            })
                            Local2 = 0x04
                            While (Local0)
                            {
                                Divide (Local0, 0x0A, Local1, Local0)
                                SERN [Local2] = (Local1 + 0x30)
                                Local2--
                            }

                            PBIF [0x0A] = SERN /* \_SB_.PCI0.LPCB.EC0_.BAT0._BIF.SERN */
                            Name (DCH0, Buffer (0x0A)
                            {
                                 0x00                                             // .
                            })
                            Name (DCH1, "LION")
                            Name (DCH2, "LiP")
                            If ((B1TY == One))
                            {
                                DCH0 = DCH1 /* \_SB_.PCI0.LPCB.EC0_.BAT0._BIF.DCH1 */
                                PBIF [0x0B] = ToString (DCH0, Ones)
                            }
                            Else
                            {
                                DCH0 = DCH2 /* \_SB_.PCI0.LPCB.EC0_.BAT0._BIF.DCH2 */
                                PBIF [0x0B] = ToString (DCH0, Ones)
                            }

                            Name (BMNT, Buffer (0x0A)
                            {
                                 0x00                                             // .
                            })
                            BMNT = RECB(0x8F,72) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x8F,72) */
                            PBIF [0x0C] = ToString (BMNT, Ones)
                            Release (LFCM)
                        }
                    }

                    Return (PBIF) /* \_SB_.PCI0.LPCB.EC0_.BAT0.PBIF */
                }
                Method (_BST, 0, Serialized)  // _BST: Battery Status
                {
                    If ((ECAV == One))
                    {
                        If ((Acquire (LFCM, 0xA000) == Zero))
                        {
                            Sleep (0x10)
                            Local0 = B1ST /* \_SB_.PCI0.LPCB.EC0_.B1ST */
                            Local1 = DerefOf (PBST [Zero])
                            Switch ((Local0 & 0x07))
                            {
                                Case (Zero)
                                {
                                    OBST = (Local1 & 0xF8)
                                }
                                Case (One)
                                {
                                    OBST = (One | (Local1 & 0xF8))
                                }
                                Case (0x02)
                                {
                                    OBST = (0x02 | (Local1 & 0xF8))
                                }
                                Case (0x04)
                                {
                                    OBST = (0x04 | (Local1 & 0xF8))
                                }

                            }

                            Sleep (0x10)
                            OBAC = B1B2(B1A0,B1A1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1A0,B1A1) */
                            If ((OBST & One))
                            {
                                If ((OBAC != Zero))
                                {
                                    OBAC = (~OBAC & 0x7FFF)
                                }
                            }

                            Sleep (0x10)
                            OBRC = B1B2(B1RX,B1RY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1RX,B1RY) */
                            Sleep (0x10)
                            OBPV = B1B2(B1FX,B1FY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                            OBRC *= 0x0A
                            OBPR = ((OBAC * OBPV) / 0x03E8)
                            PBST [Zero] = OBST /* \_SB_.PCI0.LPCB.EC0_.BAT0.OBST */
                            PBST [One] = OBPR /* \_SB_.PCI0.LPCB.EC0_.BAT0.OBPR */
                            PBST [0x02] = OBRC /* \_SB_.PCI0.LPCB.EC0_.BAT0.OBRC */
                            PBST [0x03] = OBPV /* \_SB_.PCI0.LPCB.EC0_.BAT0.OBPV */
                            Release (LFCM)
                        }
                    }

                    Return (PBST) /* \_SB_.PCI0.LPCB.EC0_.BAT0.PBST */
                }
            }
            
            Scope (\_SB.PCI0.LPCB.EC0)
            {
                Device (VPC0)
                {
                    Name (VBAC, Zero)
                    Name (VBRC, Zero)
                    Name (VBPV, Zero)
                    Name (VBFC, Zero)
                    Name (VBCT, Zero)
                    Name (QBAC, Zero)
                    Name (QBRC, Zero)
                    Name (QBPV, Zero)
                    Name (QBFC, Zero)
                    Name (QBCT, Zero)
                    Method (SMTF, 1, NotSerialized)
                    {
                        If (ECAV)
                        {
                            If ((Acquire (LFCM, 0xA000) == Zero))
                            {
                                If ((Arg0 == Zero))
                                {
                                    If ((B1B2(B1F0,B1F1) == Zero))
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }

                                    If ((B1B2(B1A0,B1A1) == Zero))
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }

                                    Local0 = B1B2(B1FX,B1FY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                                    Local0 *= 0x0A
                                    VBFC = Local0
                                    Local1 = B1B2(B1RX,B1RY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1RX,B1RY) */
                                    Local1 *= 0x0A
                                    VBRC = Local1
                                    If ((VBFC > VBRC))
                                    {
                                        VBPV = B1B2(B1F0,B1F1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                                        VBAC = B1B2(B1A0,B1A1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1A0,B1A1) */
                                        Local0 -= Local1
                                        Local1 = (VBAC * VBPV)
                                        Local3 = (Local0 * 0x03E8)
                                        Local3 = (Local3 * 0x3C)
                                        VBCT = (Local3 / Local1)
                                        Release (LFCM)
                                        Return (VBCT) /* \_SB_.PCI0.LPCB.EC0_.VPC0.VBCT */
                                    }
                                    Else
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }
                                }

                                If ((Arg0 == One))
                                {
                                    Release (LFCM)
                                    Return (0xFFFF)
                                }

                                Release (LFCM)
                            }
                        }

                        Return (0xFFFF)
                    }
                    
                    Method (SMTE, 1, NotSerialized)
                    {
                        If (ECAV)
                        {
                            If ((Acquire (LFCM, 0xA000) == Zero))
                            {
                                If ((Arg0 == Zero))
                                {
                                    If ((B1B2(B1F0,B1F1) == Zero))
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }

                                    If ((B1B2(B1A0,B1A1) == Zero))
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }

                                    Local0 = B1B2(B1RX,B1RY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1RX,B1RY) */
                                    Local0 *= 0x0A
                                    QBRC = Local0
                                    Local1 = B1B2(B1FX,B1FY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                                    Local1 *= 0x0A
                                    QBFC = Local1
                                    If ((QBFC > QBRC))
                                    {
                                        QBPV = B1B2(B1F0,B1F1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                                        If (((B1B2(B1A0,B1A1) & 0x8000) == Zero))
                                        {
                                            QBAC = B1B2(B1A0,B1A1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1A0,B1A1) */
                                        }
                                        Else
                                        {
                                            QBAC = (0xFFFF - B1B2(B1A0,B1A1))
                                        }

                                        Local1 = (QBAC * QBPV)
                                        Local3 = (Local0 * 0x03E8)
                                        Local3 = (Local3 * 0x3C)
                                        QBCT = (Local3 / Local1)
                                        Release (LFCM)
                                        Return (QBCT) /* \_SB_.PCI0.LPCB.EC0_.VPC0.QBCT */
                                    }
                                    Else
                                    {
                                        Release (LFCM)
                                        Return (0xFFFF)
                                    }
                                }

                                If ((Arg0 == One))
                                {
                                    Release (LFCM)
                                    Return (0xFFFF)
                                }

                                Release (LFCM)
                            }
                        }

                        Return (0xFFFF)
                    }
                    
                    Method (MHPF, 1, NotSerialized)
                    {
                        If (ECAV)
                        {
                            If ((Acquire (LFCM, 0xA000) == Zero))
                            {
                                Name (BFWB, Buffer (0x25){})
                                CreateByteField (BFWB, Zero, FB0)
                                CreateByteField (BFWB, One, FB1)
                                CreateByteField (BFWB, 0x02, FB2)
                                CreateByteField (BFWB, 0x03, FB3)
                                CreateField (BFWB, 0x20, 0x0100, FB4)
                                CreateByteField (BFWB, 0x24, FB5)
                                If ((SizeOf (Arg0) <= 0x25))
                                {
                                    If ((SMPR != Zero))
                                    {
                                        FB1 = SMST /* \_SB_.PCI0.LPCB.EC0_.SMST */
                                    }
                                    Else
                                    {
                                        BFWB = Arg0
                                        SMAD = FB2 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB2_ */
                                        SMCM = FB3 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB3_ */
                                        BCNT = FB5 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB5_ */
                                        Local0 = FB0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB0_ */
                                        If (((Local0 & One) == Zero))
                                        {
                                            SMDA = FB4 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB4_ */
                                        }

                                        SMST = Zero
                                        SMPR = FB0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB0_ */
                                        Local1 = 0x03E8
                                        While (Local1)
                                        {
                                            Sleep (One)
                                            Local1--
                                            If (((SMST && 0x80) || (SMPR == Zero)))
                                            {
                                                Break
                                            }
                                        }

                                        Local0 = FB0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.FB0_ */
                                        If (((Local0 & One) != Zero))
                                        {
                                            FB4 = RECB(0x64, 256) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x64, 256) */
                                        }

                                        FB1 = SMST /* \_SB_.PCI0.LPCB.EC0_.SMST */
                                        If (((Local1 == Zero) || !(SMST && 0x80)))
                                        {
                                            SMPR = Zero
                                            FB1 = 0x92
                                        }
                                    }

                                    Release (LFCM)
                                    Return (BFWB) /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHPF.BFWB */
                                }

                                Release (LFCM)
                            }
                        }
                    }
                    Method (MHIF, 1, NotSerialized)
                    {
                        If (ECAV)
                        {
                            If ((Acquire (LFCM, 0xA000) == Zero))
                            {
                                P80H = 0x50
                                If ((Arg0 == Zero))
                                {
                                    Name (RETB, Buffer (0x0A){})
                                    Name (BUF1, Buffer (0x08){})
                                    BUF1 = RECB(0x14, 64) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x14, 64) */
                                    CreateByteField (BUF1, Zero, FW0)
                                    CreateByteField (BUF1, One, FW1)
                                    CreateByteField (BUF1, 0x02, FW2)
                                    CreateByteField (BUF1, 0x03, FW3)
                                    CreateByteField (BUF1, 0x04, FW4)
                                    CreateByteField (BUF1, 0x05, FW5)
                                    CreateByteField (BUF1, 0x06, FW6)
                                    CreateByteField (BUF1, 0x07, FW7)
                                    RETB [Zero] = FUSL /* \_SB_.PCI0.LPCB.EC0_.FUSL */
                                    RETB [One] = FUSH /* \_SB_.PCI0.LPCB.EC0_.FUSH */
                                    RETB [0x02] = FW0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW0_ */
                                    RETB [0x03] = FW1 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW1_ */
                                    RETB [0x04] = FW2 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW2_ */
                                    RETB [0x05] = FW3 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW3_ */
                                    RETB [0x06] = FW4 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW4_ */
                                    RETB [0x07] = FW5 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW5_ */
                                    RETB [0x08] = FW6 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW6_ */
                                    RETB [0x09] = FW7 /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.FW7_ */
                                    Release (LFCM)
                                    Return (RETB) /* \_SB_.PCI0.LPCB.EC0_.VPC0.MHIF.RETB */
                                }

                                Release (LFCM)
                            }
                        }
                    }
                    Method (GSBI, 1, NotSerialized)
                    {
                        Name (BIFB, Buffer (0x53)
                        {
                            /* 0000 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0008 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0010 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0018 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0020 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0028 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0030 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0038 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0040 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0048 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                            /* 0050 */  0xFF, 0xFF, 0xFF                                 // ...
                        })
                        CreateWordField (BIFB, Zero, DCAP)
                        CreateWordField (BIFB, 0x02, FCAP)
                        CreateWordField (BIFB, 0x04, RCAP)
                        CreateWordField (BIFB, 0x06, ATTE)
                        CreateWordField (BIFB, 0x08, ATTF)
                        CreateWordField (BIFB, 0x0A, BTVT)
                        CreateWordField (BIFB, 0x0C, BTCT)
                        CreateWordField (BIFB, 0x0E, BTMP)
                        CreateWordField (BIFB, 0x10, MDAT)
                        CreateWordField (BIFB, 0x12, FUDT)
                        CreateWordField (BIFB, 0x14, DVLT)
                        CreateField (BIFB, 0xB0, 0x50, DCHE)
                        CreateField (BIFB, 0x0100, 0x40, DNAM)
                        CreateField (BIFB, 0x0140, 0x60, MNAM)
                        CreateField (BIFB, 0x01A0, 0xB8, BRNB)
                        CreateQWordField (BIFB, 0x4B, BFW0)
                        If (((Arg0 == Zero) || (Arg0 == One)))
                        {
                            If ((ECON == One))
                            {
                                If ((Acquire (LFCM, 0xA000) == Zero))
                                {
                                    Local0 = B1B2(B1DX,B1DY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1DX,B1DY) */
                                    Local0 *= 0x0A
                                    DCAP = Local0
                                    Local0 = B1B2(B1FX,B1FY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1F0,B1F1) */
                                    Local0 *= 0x0A
                                    FCAP = Local0
                                    Local0 = B1B2(B1RX,B1RY) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1RX,B1RY) */
                                    Local0 *= 0x0A
                                    RCAP = Local0
                                    ATTE = SMTE (Zero)
                                    ATTF = SMTF (Zero)
                                    BTVT = B1B2(B1F0,B1F1) /* \_SB_.PCI0.LPCB.EC0_.B1FV */
                                    BTCT = B1B2(B1A0,B1A1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1A0,B1A1) */
                                    Local0 = B1AT /* \_SB_.PCI0.LPCB.EC0_.B1AT */
                                    Local0 += 0x0111
                                    Local0 *= 0x0A
                                    BTMP = Local0
                                    MDAT = B1B2(B1DI,B1DJ) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1DI,B1DJ) */
                                    If ((B1B2(BFU0,BFU1) != Zero))
                                    {
                                        FUDT = B1B2(BFU0,BFU1) /* \_SB_.PCI0.LPCB.EC0_.BFUD */
                                    }

                                    DVLT = B1B2(B1D0,B1D1) /* \_SB_.PCI0.LPCB.EC0_.B1B2(B1D0,B1D1) */
                                    Name (DCH0, Buffer (0x0A)
                                    {
                                         0x00                                             // .
                                    })
                                    Name (DCH1, "LION")
                                    Name (DCH2, "LiP")
                                    If ((B1TY == One))
                                    {
                                        DCH0 = DCH1 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.DCH1 */
                                        DCHE = DCH0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.DCH0 */
                                    }
                                    Else
                                    {
                                        DCH0 = DCH2 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.DCH2 */
                                        DCHE = DCH0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.DCH0 */
                                    }

                                    Name (BDNT, Buffer (0x08)
                                    {
                                         0x00                                             // .
                                    })
                                    BDNT = RECB(0x98,64) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x98,64) */
                                    DNAM = BDNT /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.BDNT */
                                    Name (BMNT, Buffer (0x0C)
                                    {
                                         0x00                                             // .
                                    })
                                    BMNT = RECB(0x8F,72) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x8F,72) */
                                    MNAM = BMNT /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.BMNT */
                                    Name (BRN0, Buffer (0x17)
                                    {
                                         0x00                                             // .
                                    })
                                    Local1 = 0x17
                                    Local2 = 0x2E
                                    While (Local1)
                                    {
                                        BRN0 [(0x17 - Local1)] = LRAM (0x02, Local2)
                                        Local2++
                                        Local1--
                                    }

                                    BRNB = BRN0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.BRN0 */
                                    BFW0 = RECB(0x14, 64) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x14, 64) */
                                    Release (LFCM)
                                }
                            }

                            Return (BIFB) /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.BIFB */
                        }

                        If ((Arg0 == 0x02))
                        {
                            Return (BIFB) /* \_SB_.PCI0.LPCB.EC0_.VPC0.GSBI.BIFB */
                        }

                        Return (Zero)
                    }
                    Method (GBID, 0, Serialized)
                    {
                        Name (GBUF, Package (0x04)
                        {
                            Buffer (0x02)
                            {
                                 0x00, 0x00                                       // ..
                            }, 

                            Buffer (0x02)
                            {
                                 0x00, 0x00                                       // ..
                            }, 

                            Buffer (0x08)
                            {
                                 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                            }, 

                            Buffer (0x08)
                            {
                                 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                            }
                        })
                        If (ECAV)
                        {
                            If ((Acquire (LFCM, 0xA000) == Zero))
                            {
                                DerefOf (GBUF [Zero]) [Zero] = B1CT /* \_SB_.PCI0.LPCB.EC0_.B1CT */
                                DerefOf (GBUF [One]) [Zero] = Zero
                                Name (BUF1, Buffer (0x08){})
                                BUF1 = RECB(0x14, 64) /* \_SB_.PCI0.LPCB.EC0_.RECB(0x14, 64) */
                                CreateByteField (BUF1, Zero, FW0)
                                CreateByteField (BUF1, One, FW1)
                                CreateByteField (BUF1, 0x02, FW2)
                                CreateByteField (BUF1, 0x03, FW3)
                                CreateByteField (BUF1, 0x04, FW4)
                                CreateByteField (BUF1, 0x05, FW5)
                                CreateByteField (BUF1, 0x06, FW6)
                                CreateByteField (BUF1, 0x07, FW7)
                                DerefOf (GBUF [0x02]) [Zero] = FW0 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW0_ */
                                DerefOf (GBUF [0x02]) [One] = FW1 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW1_ */
                                DerefOf (GBUF [0x02]) [0x02] = FW2 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW2_ */
                                DerefOf (GBUF [0x02]) [0x03] = FW3 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW3_ */
                                DerefOf (GBUF [0x02]) [0x04] = FW4 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW4_ */
                                DerefOf (GBUF [0x02]) [0x05] = FW5 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW5_ */
                                DerefOf (GBUF [0x02]) [0x06] = FW6 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW6_ */
                                DerefOf (GBUF [0x02]) [0x07] = FW7 /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.FW7_ */
                                DerefOf (GBUF [0x03]) [Zero] = Zero
                                Release (LFCM)
                            }
                        }

                        Return (GBUF) /* \_SB_.PCI0.LPCB.EC0_.VPC0.GBID.GBUF */
                    }
                }
            }
        }
    }
    OperationRegion (PRT0, SystemIO, 0x80, 0x04)
    Field (PRT0, DWordAcc, Lock, Preserve)
    {
        P80H,   32
    }
}

