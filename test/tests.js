CommandPlugin.init(
                        function(result){
                            CommandPlugin.talk(
                                function(result){
                                    alert("��ո�˵�������?:\n\n"+"    "+result);
                                },
                                function(error){
                                    alert("error:\n\n"+"    "+error);
                                }
                            );
                        },
                        function(error){
                            alert("��ʼ��ʧ��");
                        }
                    );

