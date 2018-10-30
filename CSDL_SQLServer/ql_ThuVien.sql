
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
trangThai nvarchar(30),	--Sẵn sàng, Đã mượn, Đã mất	

constraint f_CS_DS foreign key(maDS) references DauSach(maDS)
)
go

create table QuaTrinh_Muon(
idMuon int identity primary key,
maCS char(7),
maDG char(7),
ngayMuon date,
ngayHetHan date default (dateadd(day,14, getdate())),
ngayGioTra date default null,
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
