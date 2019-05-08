<html >
   <body>
      <h1>Adobe Bank</h1>
      <h2>Add Transaction</h2>
      <form >
         <table >
            <tr>
               <td>Name:</td>
               <td><input type="text" id="name"></td>
            </tr>
            <tr>
               <td>Amount:</td>
               <td><input type="number" id="amtTxt"></td>
            </tr>
            <tr>
               <td colspan="2">
                  <button type="button" id="addBtn">Add</button>
               </td>
            </tr>
         </table>
      </form>
      <hr>
      <h2>Transactions:</h2>
      <table id="expList">
         <tr>
            <th>From</th>
            <th>To</th>
            <th>Transaction</th>
         </tr>
      </table>
      <button type="button" id="getTransactions">Get transactions</button>
      <hr>
      <h2>PDF Report</h2>
      <button type="button" id="getPdfReport">Get PDF Report</button>
      <span id='pdf' name='pdf'></span><br>
      <hr>
      <h2>Spreadsheet Report</h2>
      <button type="button" id="ssbtn">Get Spreadsheet Report</button>
      <span id='ss' name='ss'></span><br>
      <hr>
     
      <h2>Mail reports</h2>
      Mail to :<input type="email" id="email">
      <button type="button" id="mailbtn">Mail</button>
      <span id='mail' name='mail'></span><br>
      <hr>
      
   </body>
</html>
<script >
   document.getElementById("addBtn").onclick = function(){
      addTransaction();
   }
   
   
   document.getElementById("getTransactions").onclick = function(){
      getTransactions();
   }
   
   document.getElementById("getPdfReport").onclick = function(){
      getPdfReport();
   }
   
   document.getElementById("ssbtn").onclick = function(){
      getSpreadSheetReport();
   }
   
   document.getElementById("mailbtn").onclick = function(){
      mail();
   }
   
</script>
<!--- cfclient code starts here --->
<cfclientsettings  mobileserver='http://localhost:8500' enabledeviceapi="false">

<cfclient>

   <!--- on client side you do not need to pre-configure datasource --->
   <cfset dsn = "rooms">
   <!--- Helper function to add epxpense row to HTML table --->
   <cffunction name="addExpenseRow" >
      cfargument name="expense_date" >
      <cfargument name="amt" >
      <cfargument name="desc" >
      <cfoutput >
         <cfsavecontent variable="rowHtml" >
            <tr>
               <td>#amt#</td>
               <td>#desc#</td>
            </tr>
         </cfsavecontent>
      </cfoutput>
      <cfset document.getElementById("expList").innerHTML += rowHtml>
   </cffunction>
   
   <!--- Called from JS script block in response to click event for addBtn --->
   <cffunction name="addTransaction" >
      <cfset var amt = Number(document.getElementById("amtTxt").value)>
      <cfset var desc = document.getElementById("name").value>
      <!--- Insert expense row into database table --->   
      <cfquery type='server' datasource="MYSQL2" result="result">
         insert into bank (fromuser,name,amount) values ("uday",
         <cfqueryparam value="#desc#" maxlength="17">
         ,
         <cfqueryparam value="#amt#" maxlength="17">
         )
      </cfquery>
      <cfset alert('Transaction has been added. Generated key : ' & #result.GENERATEDKEY#)>;
   </cffunction>
   <!--- Called from JS script block in response to click event for addBtn --->
   <cffunction name="getTransactions" >
      <!--- TODO: Do data validation --->
      <cftry>
         <!--- Insert expense row into database table --->   
         <cfquery type='server' datasource="MYSQL2" result="result" name="n2">
            select * from bank;
         </cfquery>
         <cfloop query = "n2"> 
            <cfset addTransactionToDiv(#FROMUSER#,#NAME#,#AMOUNT#)>
         </cfloop>
         <!---<cfloop array='#n.DATA#' index='idx'>
            <cfset addTransactionToDiv(#idx[1]#,#idx[2]#,#idx[3]#)>
            </cfloop>--->
         <cfcatch type="any" name="e">
            <cfset alert(e.message)>
         </cfcatch>
      </cftry>
      <!--- add the new expense row to HTML table --->
   </cffunction>
   <cffunction name="getPdfReport" >
      <cfquery type='server' datasource="MYSQL2" result="result" name="n">
         select * from bank;
      </cfquery>
      <cfset html = '<b style="font-size:40px">Your bank statement</b><br><Br>'>
      <cfloop query = "n"> 
         <cfset html+= '<b style="color:red">' & #FROMUSER# &  '</b>-' & '<i>' & #NAME# & '</i>' & ' <B>' & #AMOUNT# & '</B><br><Br>'>   
      </cfloop>
      <cfhtmltopdf destination='C:\Depot\cf_main\cfusion\wwwroot\ff\ff2.pdf' overwrite=true>
         <cfoutput>#html#</cfoutput>
      </cfhtmltopdf>
      <cfset document.getElementById("pdf").innerHTML += "Click here to view : <a target='_blank' href='http://localhost:8500/ff/ff2.pdf'>Click</a>">
   </cffunction>
   
   
   <cffunction name="getSpreadSheetReport" >
      <cfquery
         name="centers" datasource="MYSQL2"
         type="server"> 
         SELECT * FROM bank 
      </cfquery>
      <cfscript> 
         //Use an absolute path for the files. ---> 
         theDir='c:/Downloads/'; 
         theFile="C:\Depot\cf_main\cfusion\wwwroot\ff\ff.xls"; 
         //Create two empty ColdFusion spreadsheet objects. ---> 
         thesecondsheet = SpreadsheetNew(); 
      </cfscript>
      
      <cfset SpreadsheetAddRows(thesecondsheet,centers)>
      <cfspreadsheet action="write" filename="#theFile#" name="thesecondsheet"
         sheetname="centers" overwrite=true>
      <cfset document.getElementById("ss").innerHTML += "Click here to download : <a target='_blank' href='http://localhost:8500/ff/ff.xls'>Click</a>">
   </cffunction>
   <cffunction name="addTransactionToDiv" >
      <cfargument name="fromuser" >
      <cfargument name="touser" >
      <cfargument name="amt" >
      <cfoutput >
         <cfsavecontent variable="rowHtml" >
            <tr>
               <td>#fromuser#</td>
               <td>#touser#</td>
               <td>#amt#</td>
            </tr>
         </cfsavecontent>
      </cfoutput>
      <cfset document.getElementById("expList").innerHTML += rowHtml>
   </cffunction>
   
   <cffunction name="mail" >
      <cfset var to = document.getElementById("email").value>
      <cfmail to="#to#" from="bob@work.com"
         subject="Sending a mail with the encryption algo 
         This message is encrypted using the algorithm" >
         <cfmailparam name = "Importance" value = "High">
         Please review the new logo. Tell us what you think. 
         <cfmailparam name="Disposition-Notification-To" value="peter@domain.com">
	 <cfmailparam file = "http://localhost:8500/report.pdf" type="text/plain"> 
      </cfmail>
      <cfset document.getElementById("mail").innerHTML += "Check logs">
   </cffunction>
   
   
</cfclient>