export type Destination = { id: string; name: string; region: string; symbol: string; subtitle: string; story: string; question: string; options: string[]; correct: number; fact: string };
export const DESTINATIONS: Destination[] = [
  {id:'hanoi',name:'Hà Nội',region:'Miền Bắc',symbol:'🏯',subtitle:'Khởi hành từ phố cổ',story:'An nhận cuốn hộ chiếu của bà: “Đi để hiểu những miền đất và con người Việt Nam.” Hãy tìm dấu đầu tiên giữa lòng thủ đô.',question:'Hồ nào gắn với truyền thuyết vua Lê trả gươm?',options:['Hồ Tây','Hồ Hoàn Kiếm','Hồ Ba Bể'],correct:1,fact:'Hồ Hoàn Kiếm còn gọi là Hồ Gươm, gắn với truyền thuyết vua Lê Lợi trả gươm cho Rùa Vàng.'},
  {id:'halong',name:'Hạ Long',region:'Miền Bắc',symbol:'⛵',subtitle:'Giữa ngàn đảo đá',story:'Một người lái đò kể cho An nghe câu chuyện về rồng hạ xuống biển. Nhiệm vụ: tìm hiểu kỳ quan đá vôi.',question:'Vịnh Hạ Long nổi bật bởi cảnh quan nào?',options:['Núi đá vôi trên biển','Đồi cát đỏ','Rừng thông cao nguyên'],correct:0,fact:'Vịnh Hạ Long nổi tiếng với các đảo đá vôi và hệ thống hang động giữa biển.'},
  {id:'ninhbinh',name:'Ninh Bình',region:'Miền Bắc',symbol:'🌿',subtitle:'Mái chèo qua Tràng An',story:'An đi thuyền qua những dãy núi xanh. Bà để lại một gợi ý: nơi đây từng là vùng đất cố đô.',question:'Cố đô nào nằm tại Ninh Bình?',options:['Phú Xuân','Hoa Lư','Cổ Loa'],correct:1,fact:'Hoa Lư là kinh đô của nhà Đinh và Tiền Lê vào thế kỷ X.'},
  {id:'hue',name:'Huế',region:'Miền Trung',symbol:'🪷',subtitle:'Lắng nghe miền di sản',story:'Bên dòng Hương, An gặp một nghệ nhân. Nhiệm vụ: khám phá di sản âm nhạc cung đình.',question:'Loại hình âm nhạc cung đình nổi tiếng của Huế là gì?',options:['Đờn ca tài tử','Quan họ','Nhã nhạc'],correct:2,fact:'Nhã nhạc cung đình Việt Nam gắn với triều đình và được gìn giữ, biểu diễn tại Huế.'},
  {id:'hoian',name:'Hội An',region:'Miền Trung',symbol:'🏮',subtitle:'Đêm vàng bên sông Hoài',story:'An nhận một chiếc đèn nhỏ từ người thợ phố cổ. Nhiệm vụ: tìm biểu tượng thắp sáng đêm Hội An.',question:'Hình ảnh nào đặc trưng cho phố cổ Hội An về đêm?',options:['Đèn lồng','Nhà băng tuyết','Cối xay gió'],correct:0,fact:'Đèn lồng là một nét văn hóa đặc trưng của Hội An, đặc biệt trong những đêm phố cổ.'},
  {id:'dalat',name:'Đà Lạt',region:'Tây Nguyên',symbol:'🌲',subtitle:'Một nhịp thở cao nguyên',story:'Sổ tay của bà có một bông hoa ép khô. An lên cao nguyên tìm thành phố của những vườn hoa và rừng thông.',question:'Đà Lạt thuộc tỉnh nào trong cách gọi địa danh quen thuộc?',options:['Khánh Hòa','Lâm Đồng','Gia Lai'],correct:1,fact:'Đà Lạt thuộc tỉnh Lâm Đồng, trên cao nguyên Lâm Viên, nổi tiếng với khí hậu mát mẻ.'},
  {id:'saigon',name:'TP. Hồ Chí Minh',region:'Miền Nam',symbol:'🏙️',subtitle:'Nhịp phố phương Nam',story:'An bước vào nhịp sống thành phố. Nhiệm vụ: nhận ra khu chợ lâu đời giữa trung tâm.',question:'Khu chợ nào là biểu tượng quen thuộc của TP. Hồ Chí Minh?',options:['Chợ Đông Ba','Chợ Đồng Xuân','Chợ Bến Thành'],correct:2,fact:'Chợ Bến Thành là một địa điểm nổi tiếng ở trung tâm TP. Hồ Chí Minh.'},
  {id:'cantho',name:'Cần Thơ',region:'Miền Tây',symbol:'🛶',subtitle:'Chợ sớm trên sông',story:'Bình minh trên sông, An viết trang cuối: mỗi miền đất đều có câu chuyện riêng. Nhiệm vụ cuối: tìm hiểu chợ nổi.',question:'Chợ nổi nổi tiếng tại Cần Thơ có tên gì?',options:['Cái Răng','Đầm Sen','Sa Pa'],correct:0,fact:'Chợ nổi Cái Răng là nét văn hóa sông nước tiêu biểu của Cần Thơ và vùng đồng bằng sông Cửu Long.'},
];
export const TRANSPORTS = [
  {id:'bus',name:'Xe khách',symbol:'🚌',cost:90,description:'Tiết kiệm · ngắm phố qua ô cửa'},
  {id:'train',name:'Tàu hỏa',symbol:'🚆',cost:140,description:'Thong thả · cảm hứng đường dài'},
  {id:'plane',name:'Máy bay',symbol:'✈️',cost:210,description:'Nhanh gọn · dành thêm thời gian khám phá'},
] as const;
export type Progress = {version:1; money:number; current:number; stamps:string[]; trips:{destination:string;transport:string;cost:number}[]};
export const INITIAL_PROGRESS: Progress = {version:1,money:1600,current:0,stamps:[],trips:[]};
export const REWARD = 80;
export function travelTo(progress:Progress,destinationId:string,transportId:string):Progress {
  const index=DESTINATIONS.findIndex(d=>d.id===destinationId);
  const transport=TRANSPORTS.find(t=>t.id===transportId);
  if(!transport || index!==progress.current+1 || !progress.stamps.includes(DESTINATIONS[progress.current]?.id) || progress.money<transport.cost) return progress;
  return {...progress,current:index,money:progress.money-transport.cost,trips:[...progress.trips,{destination:destinationId,transport:transport.id,cost:transport.cost}]};
}
export function answerQuestion(progress:Progress,destinationId:string,option:number): {progress:Progress;correct:boolean;alreadyStamped:boolean} {
 const destination=DESTINATIONS[progress.current];
 const alreadyStamped=progress.stamps.includes(destinationId);
 const correct=destination?.id===destinationId && Number.isInteger(option) && option===destination.correct;
 if(!correct || alreadyStamped) return {progress,correct,alreadyStamped};
 return {progress:{...progress,money:progress.money+REWARD,stamps:[...progress.stamps,destinationId]},correct:true,alreadyStamped:false};
}
export function sanitizeProgress(value:unknown):Progress {
 if(!value || typeof value!=='object') throw new Error('Dữ liệu lưu không hợp lệ');
 const p=value as Partial<Progress>;
 if(p.version!==1 || !Number.isInteger(p.current) || p.current!<0 || p.current!>=DESTINATIONS.length || !Number.isInteger(p.money) || p.money!<0 || p.money!>2240 || !Array.isArray(p.stamps) || !Array.isArray(p.trips)) throw new Error('Dữ liệu lưu không hợp lệ');
 const current=p.current!;
 const expectedIds=DESTINATIONS.slice(0,current).map(d=>d.id);
 if(p.stamps.length<current || p.stamps.length>current+1 || p.stamps.some((id,i)=>id!==DESTINATIONS[i]?.id) || expectedIds.some(id=>!p.stamps!.includes(id)) || p.trips.length!==current) throw new Error('Tiến trình lưu không hợp lệ');
 let costs=0;
 for(let i=0;i<p.trips.length;i++) {
  const trip=p.trips[i]; const transport=TRANSPORTS.find(t=>t.id===trip?.transport);
  if(!transport || trip.destination!==DESTINATIONS[i+1].id || trip.cost!==transport.cost) throw new Error('Chuyến đi lưu không hợp lệ');
  costs+=transport.cost;
 }
 if(p.money!==INITIAL_PROGRESS.money+REWARD*p.stamps.length-costs) throw new Error('Ngân sách lưu không hợp lệ');
 return {version:1,current,money:p.money!,stamps:[...p.stamps],trips:p.trips.map(t=>({...t}))};
}
