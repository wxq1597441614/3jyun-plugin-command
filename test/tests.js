CommandPlugin.init(
                        function(result){
                            CommandPlugin.talk(
                                function(result){
                                    alert("你刚刚说的是这个?:\n\n"+"    "+result);
                                },
                                function(error){
                                    alert("error:\n\n"+"    "+error);
                                }
                            );
                        },
                        function(error){
                            alert("初始化失败");
                        }
                    );

