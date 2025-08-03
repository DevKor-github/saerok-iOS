VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image.SRIconSet.pin
                        .frame(.defaultIconSize)
                    Text("\(address)")
                        .font(.SRFontSet.subtitle2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
                
                ScrollView {
                    LazyVStack(spacing: 7) {
                        ForEach(item, id: \.collectionId) { item in
                            NearbyCell(item: item)
                        }
                        Color.clear
                            .frame(height: 180)
                    }
                    .padding(9)
                }
            }
            .background(Color.srLightGray)
        }