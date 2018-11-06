
--+--+--+--+--+---Database----+--+--+--+--+--+--+--+--+--+--
create database QL_ThuVien;
go

use QL_ThuVien;
go

--------Tao Bang---Primary Key----Foreign Key------------------------

create table LoaiDocGia(
maLoaiDG int primary key, 
tenLoaiDG nvarchar(30),
soSachMuonToiDa int
)
go



create table DocGia(
maDG char(7) primary key,  --DG00001, DG00002, .....
loaiDG int default 1,
hoTen nvarchar(50),
ngaySinh date,
diaChi nvarchar(100),
soDT int,
tichDiem int default 0, --Cứ tăng 100đ thì tự Up lên 1 cấp độc giả(loại độc giả)

constraint fk_DG_LoaiDG foreign key(loaiDG) references LoaiDocGia(maLoaiDG)
)
go

create table TheLoaiSach(
maTheLoai int identity primary key,
tenTheLoai nvarchar(100), --Tiểu thuyết, Trinh thám,...
)
go

create table NhaXuatBan(
maNXB int identity primary key,
tenNXB nvarchar(100),
diaChi nvarchar(100),
soDT int
)
go

create table DauSach(
maDS char(7) primary key,
tenDS nvarchar(100),
tacGia nvarchar(100),
theLoai int,
NXB int,
soLuong int default 0,

constraint fk_DS_TL foreign key(theLoai) references TheLoaiSach(maTheLoai),
constraint fk_DS_NXB foreign key(NXB) references NhaXuatBan(maNXB)
)
go


create table CuonSach(
maCS char(7) primary key,	--CS00001, CS00002, ....
maDS char(7),
ngonNgu nvarchar(30),
taiBan nvarchar(20),	--lần 1, lần 2.....
trangThai nvarchar(30) default N'Sẵn sàng',	--Sẵn sàng, Đã mượn, Đã mất	

constraint f_CS_DS foreign key(maDS) references DauSach(maDS)
)
go


create table QuaTrinh_Muon(
idMuon int identity primary key,
maCS char(7),
maDG char(7),
ngayMuon date,
ngayHetHan date default (dateadd(day,14, getdate())),
ngayTra date default null,
ghiChu nvarchar(100) default null,
soLanGiaHan int default 0,

constraint fk_Muon_CS foreign key(maCS) references CuonSach(maCS),
constraint fk_Muon_DG foreign key(maDG) references DocGia(maDG),
)


-------------------------------Insert dữ liệu cần thiết----------------------

insert into LoaiDocGia values (1, 'Thành viên mới', 3)
insert into LoaiDocGia values (2, 'Thân quen', 4)
insert into LoaiDocGia values (3, 'VIP', 5)


insert  into TheLoaiSach values('Tiểu thuyết')
insert  into TheLoaiSach values('Trinh thám')
insert  into TheLoaiSach values('Ngôn Tình')
insert  into TheLoaiSach values('Truyện tranh')
insert  into TheLoaiSach values('Giáo trình')
insert  into TheLoaiSach values('Tâm lý')


insert into NhaXuatBan values ('Nhà xuất bản Giáo dục', 'Sở giáo dực đào tạo Hà Nội', 0909555777)
insert into NhaXuatBan values ('Nhà xuất bản Văn hóa', 'Nhà văn hóa thiếu niên, quận 9, tp.HCM', 0983999777)
insert into NhaXuatBan values ('Nhà xuất bản Nhi đồng', 'Nhà văn hóa thiếu niên nhi đồng, quận 1, tp.HCM ', 0907444777)
insert into NhaXuatBan values ('Nhà xuất bản Phương nam', 'quận 1, tp.HCM', 0169789777)
insert into NhaXuatBan values ('Nhà xuất bản Mới', 'Linh Trung, Thủ Đức, tp.HCM', 0903888777)





insert into DauSach (mads, tends, tacgia, theLoai, nxb) values ('DS00001', N'Trộm chó', N'Trịnh Hoàng', 1, 1)
insert into DauSach (mads, tends, tacgia, theLoai, nxb) values ('DS00002', N'Đặt tên sao cho nó dài thật là dài :))', N'Trịnh Lâm', 2, 2)

insert into CuonSach (maCS,mads,ngonngu,taiban) values ('CS00001', 'DS00001', N'Tiếng việt', N'Lần 1')
insert into CuonSach (maCS,mads,ngonngu,taiban) values ('CS00002', 'DS00001', N'Tiếng việt', N'Lần 1')
insert into CuonSach (maCS,mads,ngonngu,taiban) values ('CS00003', 'DS00001', N'Tiếng việt', N'Lần 1')
insert into CuonSach (maCS,mads,ngonngu,taiban) values ('CS00004', 'DS00002', N'Tiếng việt', N'Lần 1')

insert into QuaTrinh_Muon (maCS, maDG, ngayMuon) values ('CS00001', 'DG00001', '1/1/2018')
insert into QuaTrinh_Muon (maCS, maDG, ngayMuon) values ('CS00002', 'DG00001', '11/1/2018')
insert into QuaTrinh_Muon (maCS, maDG, ngayMuon,ngayHetHan) values ('CS00003', 'DG00001', '1/1/2018','2/2/2018')
go
---------------------------- -+- Trigger----------------------------


create trigger tg_Update_SL_DS
on CuonSach
for insert 
as
begin
	update DauSach
	set soLuong+=1
	where maDS = (select maDS from inserted)
end
go


create trigger tg_UpdateTrangThaiSach
on QuaTrinh_Muon
for insert , update
as
begin
	if exists (select * from inserted where ngayTra is null)
		begin
			update CuonSach set trangThai = N'Đang cho mượn' where maCS = (select maCS from inserted)
		end
	else
		begin
			update CuonSach set trangThai = N'Sẵn sàng' where maCS = (select maCS from inserted)
		end
end
go


-----------------------------Store Procedure-------------------------

create proc getTableMuonSach(@TenSachTraCuu nvarchar(70))
as
begin
	DECLARE @str NVARCHAR(150) = N'%', @i INT =1, @length INT;
	SELECT @length = LEN(@TenSachTraCuu)

	WHILE (@i < @length OR @i = @length )
		BEGIN
			SET @str = CONCAT(@str,SUBSTRING(@TenSachTraCuu,@i,1), '%');	
			SET @i = @i + 1;
		END 
	
	select maCS, tenDS,ngonNgu, taiBan, trangThai
	from CuonSach cs join DauSach ds on cs.maDS=ds.maDS
	where tenDS like @str

end
go





--select * from dausach
--select * from CuonSach
--select * from QuaTrinh_Muon